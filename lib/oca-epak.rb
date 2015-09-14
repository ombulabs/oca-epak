require 'savon'

class Oca
  attr_reader :client

  WSDL_BASE_URI = 'http://webservice.oca.com.ar/oep_tracking/Oep_Track.asmx?'\
                  'WSDL'.freeze

  def initialize
    @client = Savon.client(wsdl: WSDL_BASE_URI)
  end

  # Get rate for a corporate shipment
  #
  # @param [String] Total Weight
  # @param [String] Total Volume
  # @param [String] Origin ZIP Code
  # @param [String] Destination ZIP Code
  # @param [String] Quantity of Packages
  # @param [String] Declared Monetary Value
  # @return [Savon::Response] Contains Shipping Price
  def get_corporate_shipping_rate(weight, volume, origin, destination, qty, val)
  end

  # Given a client's CUIT with a range of dates, a list is returned with
  # all shipments made for the given period.
  #
  # @param [String] "From date" in DD-MM-YYYY format
  # @param [String] "To date" in DD-MM-YYYY format
  # @return [Savon::Response] Contains the values for NroProducto and NumeroEnvio
  def list_shipments(from_date, to_date)
    opts = { FechaDesde: from_date, FechaHasta: to_date }
    response = client.call(:list_envios, message: opts)
    response.body
  end

  # Returns all existing "Centros de Imposición"
  #
  # @return [Array] Information for all the Centros de Imposición
  def centros_de_imposicion
    response = client.call(:get_centros_imposicion)
    if body = response.body[:get_centros_imposicion_response]
      body[:get_centros_imposicion_result][:diffgram][:new_data_set][:table]
    end
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
end
