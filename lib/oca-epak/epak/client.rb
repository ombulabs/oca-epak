module Oca
  module Epak
    class Client < BaseClient
      ONE_STRING = "1".freeze
      USER_STRING = "usr".freeze
      PASSWORD_STRING = "psw".freeze
      WSDL_URL = "#{BASE_WSDL_URL}/epak_tracking/Oep_TrackEPak.asmx?wsdl".freeze

      def initialize(username, password)
        super
        @opts = { wsdl: WSDL_URL }.merge(Oca::Logger.options)
        @client = Savon.client(@opts)
      end

      # Checks if the user has input valid credentials
      #
      # @return [Boolean] Whether the credentials entered are valid or not
      def check_credentials
        method = :get_epack_user
        opts = { USER_STRING => username, PASSWORD_STRING => password }
        response = client.call(method, message: opts)
        parse_results_table(response, method).first[:existe] == ONE_STRING
      end

      # Creates a Pickup Order, which lets OCA know you want to make a delivery.
      #
      # @see https://github.com/ombulabs/oca-epak/blob/master/doc/OCAWebServices.pdf
      #
      # @param [Hash] opts
      # @option opts [Oca::Epak::PickupData] :pickup_data Pickup Data object
      # @option opts [Boolean] :confirm_pickup Confirm Pickup? Defaults to false
      # @option opts [Integer] :days_to_pickup Days OCA should wait before pickup, default: 1
      # @option opts [Integer] :pickup_range Range to be used when picking it up, default: 1
      # @return [Hash, nil]
      def create_pickup_order(opts = {})
        confirm_pickup = opts.fetch(:confirm_pickup, FALSE_STRING)
        days_to_pickup = opts.fetch(:days_to_pickup, ONE_STRING)
        pickup_range = opts.fetch(:pickup_range, ONE_STRING)
        rendered_xml = opts[:pickup_data].to_xml

        message = { USER_STRING => username, PASSWORD_STRING => password,
                    "xml_Datos" => rendered_xml,
                    "ConfirmarRetiro" => confirm_pickup.to_s,
                    "DiasHastaRetiro" => days_to_pickup,
                    "idFranjaHoraria" => pickup_range }
        response = client.call(:ingreso_or, message: message)
        parse_result(response, :ingreso_or)
      end

      # Get rates and delivery estimate for a shipment
      #
      # @param [Hash] opts
      # @option opts [String] :total_weight Total Weight e.g: 20
      # @option opts [String] :total_volume Total Volume e.g: 0.0015
      #                                (0.1mts * 0.15mts * 0.1mts)
      # @option opts [String] :origin_zip_code Origin ZIP Code
      # @option opts [String] :destination_zip_code Destination ZIP Code
      # @option opts [String] :declared_value Declared Value
      # @option opts [String] :package_quantity Quantity of Packages
      # @option opts [String] :cuit Client's CUIT e.g: 30-99999999-7
      # @option opts [String] :operation_code Operation Type
      # @return [Hash, nil] Contains Total Price, Delivery Estimate
      def get_shipping_rate(opts = {})
        method = :tarifar_envio_corporativo
        message = { "PesoTotal" => opts[:total_weight],
                    "VolumenTotal" => opts[:total_volume],
                    "CodigoPostalOrigen" => opts[:origin_zip_code],
                    "CodigoPostalDestino" => opts[:destination_zip_code],
                    "ValorDeclarado" => opts[:declared_value],
                    "CantidadPaquetes" => opts[:package_quantity],
                    "Cuit" => opts[:cuit],
                    "Operativa" => opts[:operation_code] }
        response = client.call(method, message: message)
        parse_results_table(response, method).first
      end

      # Returns all existing Taxation Centers
      #
      # @return [Array, nil] Information for all the Oca Taxation Centers
      def taxation_centers
        method = :get_centros_imposicion
        response = client.call(method)
        parse_results_table(response, method)
      end

      # Returns all existing Taxation Centers with services
      #
      # @return [Array, nil] Information for all the Oca Taxation Centers with services
      def taxation_centers_with_services
        method = :get_centros_imposicion_con_servicios
        response = client.call(method)
        parse_result(response, method)
      end

      # Returns all operation codes
      #
      # @return [Array, nil] Returns all operation codes available for the user
      def get_operation_codes
        method = :get_operativas_by_usuario
        opts = { USER_STRING => username, PASSWORD_STRING => password }
        response = client.call(method, message: opts)
        parse_results_table(response, method)
      end

      # Given a client's CUIT with a range of dates, returns a list with
      # all shipments made within the given period.
      #
      # @param [String] Client's CUIT
      # @param [String] "From date" in DD-MM-YYYY format
      # @param [String] "To date" in DD-MM-YYYY format
      # @return [Array, nil] Contains an array of hashes with NroProducto and NumeroEnvio
      def list_shipments(cuit, from_date, to_date)
        method = :list_envios
        opts = { "CUIT" => cuit, "FechaDesde" => from_date,
                 "FechaHasta" => to_date }
        response = client.call(method, message: opts)
        parse_results_table(response, method)
      end

      # Returns all provinces in Argentina
      #
      # @return [Array, nil] Provinces in Argentina with their ID and name as a Hash
      def provinces
        response = client.call(:get_provincias)
        if body = response.body[:get_provincias_response]
          body[:get_provincias_result][:provincias][:provincia]
        end
      end

      # Get the tracking history of an object
      #
      # @param [Hash] opts
      # @option opts [String] :cuit Client's CUIT e.g: 30-99999999-7
      # @option opts [String] :pieza Tracking number
      # @return [Hash, nil] Contains the history of object's movement.
      def tracking_object(opts = {})
        message = {
          "Cuit" => opts[:cuit],
          "Pieza" => opts[:pieza]
        }

        response = client.call(:tracking_pieza, message: message)
        parse_result(response, :tracking_pieza)
      end
    end
  end
end
