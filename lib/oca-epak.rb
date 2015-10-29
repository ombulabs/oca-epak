require 'savon'

class Oca
  attr_reader :client

  WSDL = 'http://webservice.oca.com.ar/oep_tracking/Oep_Track.asmx?WSDL'.freeze

  def initialize
    @client = Savon.client(wsdl: WSDL)
  end

  # Checks if the user has input valid credentials
  #
  # @param [String] Username (Email)
  # @param [String] Password
  # @return [Boolean] Whether the credentials are valid or not
  def check_credentials(username, password)
    begin
      opts = { "usr" => username, "psw" => password }
      client.call(:generar_consolidacion_de_ordenes_de_retiro, message: opts)
      false
    rescue Savon::SOAPFault => e
      true
    end
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
    parse_results(method, response)
  end

  # Returns all existing Taxation Centers
  #
  # @return [Array, nil] Information for all the Oca Taxation Centers
  def taxation_centers
    method = :get_centros_imposicion
    response = client.call(method)
    parse_results(method, response)
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
    parse_results(method, response)
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

    def parse_results(method, response)
      method_response = "#{method}_response".to_sym
      method_result = "#{method}_result".to_sym
      if body = response.body[method_response]
        body[method_result][:diffgram][:new_data_set][:table]
      end
    end
end
