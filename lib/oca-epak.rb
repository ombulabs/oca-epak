require 'savon'
require 'erb'
require 'ostruct'
require 'oca-epak/pickup_data'
require 'oca-epak/errors/error'
require 'oca-epak/errors/bad_request'

module Oca
  class Epak
    attr_reader :client
    attr_accessor :username, :password

    WSDL = 'http://webservice.oca.com.ar/epak_tracking/Oep_TrackEPak.asmx?wsdl'.freeze

    def initialize(username, password)
      @client = Savon.client(wsdl: WSDL)
      @username = username
      @password = password
    end

    # Checks if the user has input valid credentials
    #
    # @return [Boolean] Whether the credentials entered are valid or not
    def check_credentials
      method = :get_epack_user
      opts = { "usr" => username, "psw" => password }
      response = client.call(method, message: opts)
      parse_results_table(response, method)[:existe] == "1"
    end

    # Checks whether the operation is valid
    #
    # @param [String] Client's CUIT
    # @param [String] Operation Type
    # @return [Boolean]
    def check_operation(cuit, op)
      begin
        opts = { wt: "50", vol: "0.027", origin: "1414", destination: "5403",
                 qty: "1", total: "123", cuit: cuit, op: op }
        get_shipping_rates(opts)
        true
      rescue Oca::Epak::Error => e
        false
      end
    end

    # Creates a Pickup Order, which lets OCA know you want to make a delivery.
    #
    # @see [http://www.ombushop.com/oca/documentation.pdf] #TODO put it there
    #
    # @param [Hash] opts
    # @option [Oca::Epak::PickupData] :pickup_data Pickup Data object
    # @option [Boolean] :confirm_pickup Confirm Pickup? Defaults to false
    # @option [Integer] :days_to_pickup Days OCA should wait before pickup, default: 1 (?) #TODO Confirm
    # @option [Integer] :pickup_range Range to be used when picking it up, default: 1
    # @return [Hash, nil]
    def create_pickup_order(opts = {})
      confirm_pickup = opts.fetch(:confirm_pickup, false)
      days_to_pickup = opts.fetch(:days_to_pickup, "1")
      pickup_range = opts.fetch(:pickup_range, "1")
      rendered_xml = opts[:pickup_data].to_xml

      message = { "usr" => username, "psw" => password,
                  "xml_Datos" => rendered_xml,
                  "ConfirmarRetiro" => confirm_pickup.to_s,
                  "DiasHastaRetiro" => opts[:days_to_pickup],
                  "idFranjaHoraria" => opts[:pickup_range] }
      response = client.call(:ingreso_or, message: message)
      parse_results_table(response, :ingreso_or)
    end

    # Get rates and delivery estimate for a shipment
    #
    # @param [Hash] opts
    # @option [String] :wt Total Weight e.g: 20
    # @option [String] :vol Total Volume e.g: 0.0015 (0.1mts * 0.15mts * 0.1mts)
    # @option [Integer] :origin Origin ZIP Code
    # @option [Integer] :destination Destination ZIP Code
    # @option [Integer] :qty Quantity of Packages
    # @option [Integer] :total Declared Value
    # @option [String] :cuit Client's CUIT e.g: 30-99999999-7
    # @option [String] :op Operation Type
    # @return [Hash, nil] Contains Total Price, Delivery Estimate
    def get_shipping_rates(opts = {})
      method = :tarifar_envio_corporativo
      message = { "PesoTotal" => opts[:wt], "VolumenTotal" => opts[:vol],
                  "CodigoPostalOrigen" => opts[:origin],
                  "CodigoPostalDestino" => opts[:destination],
                  "ValorDeclarado" => opts[:total],
                  "CantidadPaquetes" => opts[:qty], "Cuit" => opts[:cuit],
                  "Operativa" => opts[:op] }
      response = client.call(method, message: message)
      parse_results_table(response, method)
    end

    # Returns all existing Taxation Centers
    #
    # @return [Array, nil] Information for all the Oca Taxation Centers
    def taxation_centers
      method = :get_centros_imposicion
      response = client.call(method)
      parse_results_table(response, method)
    end

    # Returns all operation codes
    #
    # @return [Array, nil] Returns all operation codes available for the user
    def get_operation_codes
      method = :get_operativas_by_usuario
      opts = { "usr" => username, "psw" => password }
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

    private

      def parse_result(response, method)
        method_response = "#{method}_response".to_sym
        method_result = "#{method}_result".to_sym
        if body = response.body[method_response]
          body[method_result]
        end
      end

      def parse_results_table(response, method)
        if result = parse_result(response, method)
          if result[:diffgram][:new_data_set]
            result[:diffgram][:new_data_set][:table]
          else
            raise Oca::Epak::BadRequest.new("Oca WS responded with:\n#{response.body}")
          end
        end
      end
  end
end
