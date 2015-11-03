require 'savon'
require 'erb'
require 'ostruct'

class Oca
  attr_reader :client
  attr_accessor :username, :password

  WSDL = 'http://webservice.oca.com.ar/oep_tracking/Oep_Track.asmx?WSDL'.freeze

  def initialize(username, password)
    @client = Savon.client(wsdl: WSDL)
    @username = username
    @password = password
  end

  # Checks if the user has input valid credentials
  #
  # @return [Boolean] Whether the credentials entered are valid or not
  def check_credentials
    method = :generate_qr_by_orden_de_retiro
    opts = { "usr" => username, "psw" => password, "idOrdenDeRetiro" => "0123" }
    response = client.call(method, message: opts)
    !parse_result(response, method).to_s.include?("Invalido")
  end

  # Checks whether the operation is valid
  #
  # @param [String] Client's CUIT
  # @param [String] Operation Type
  # @return [Boolean]
  def check_operation(cuit, op)
    begin
      opts = { wt: "50", vol: "0.027", origin: "1414", destination: "5403",
               qty: "1", cuit: cuit, op: op }
      get_shipping_rates(opts)
      true
    rescue NoMethodError => e
      false
    end
  end

  # Creates a Pickup Order, which lets OCA know you want to make a delivery
  #
  # @param [Hash] opts
  # @option [String] :account_number Account Number (SAP)
  # @option [Hash] :pickup Pickup Hash
  # @option [Array<Hash>] :shipments Shipments Hash
  # @option [Boolean] :confirm_pickup Confirm Pickup? Defaults to false
  # @return [Hash, nil]
  def create_pickup_order(opts = {})
    opts[:confirm_pickup] = false unless opts.has_key?(:confirm_pickup)
    opts = OpenStruct.new(opts).instance_eval { binding }

    rendered_xml = or_template.result(opts)

    rendered_xml = rendered_xml.gsub("\t", "").gsub("\n", "")
    message = { "usr" => username, "psw" => password,
                "XML_Retiro" => rendered_xml,
                "ConfirmarRetiro" => opts[:confirm_pickup].to_s,
                "DiasRetiro" => "", "FranjaHoraria" => "" }
    response = client.call(:ingreso_or, message: message)
    parse_results_table(response, :ingreso_or)
  end

  # Get rates and delivery estimate for a shipment
  #
  # @param [Hash] opts
  # @option [String] :wt Total Weight e.g: 20
  # @option [String] :vol Total Volume e.g: 0.0015 (0.1mts * 0.15mts * 0.1mts)
  # @option [String] :origin Origin ZIP Code
  # @option [String] :destination Destination ZIP Code
  # @option [String] :qty Quantity of Packages
  # @option [String] :cuit Client's CUIT e.g: 30-99999999-7
  # @option [String] :op Operation Type
  # @return [Hash, nil] Contains Total Price, Delivery Estimate
  def get_shipping_rates(opts = {})
    method = :tarifar_envio_corporativo
    message = { "PesoTotal" => opts[:wt], "VolumenTotal" => opts[:vol],
                "CodigoPostalOrigen" => opts[:origin],
                "CodigoPostalDestino" => opts[:destination],
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
        result[:diffgram][:new_data_set][:table]
      end
    end

    def or_template
      path_to_xml = File.expand_path("../oca-epak/retiro.xml.erb", __FILE__)
      ERB.new(File.read(path_to_xml))
    end
end
