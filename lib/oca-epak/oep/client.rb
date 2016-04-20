module Oca
  module Oep
    class Client < BaseClient
      WSDL_URL = "#{BASE_WSDL_URL}/oep_tracking/Oep_Track.asmx?wsdl".freeze

      def initialize(username, password)
        super
        @client = Savon.client(wsdl: WSDL_URL)
      end

      # Returns the HTML for a label
      #
      # @param [Hash] opts
      # @option opts [Integer] :id_orden_retiro
      # @option opts [String] :nro_envio
      # @return [String] HTML
      def get_html_de_etiquetas_por_orden_or_numero_envio(opts = {})
        method = :get_html_de_etiquetas_por_orden_or_numero_envio
        opts = { "idOrdenRetiro" => opts[:id_orden_retiro],
                 "nroEnvio" => opts[:nro_envio] }
        response = client.call(method, message: opts)
        parse_result(response, method)
      end

      # Returns the PDF (Base64 encoded) String for a label
      #
      # @param [Hash] opts
      # @option opts [Integer] :id_orden_retiro
      # @option opts [String] :nro_envio
      # @option opts [Boolean] :logistica_inversa
      # @return [String] PDF data Base64 encoded
      def get_pdf_de_etiquetas_por_orden_or_numero_envio(opts = {})
        method = :get_pdf_de_etiquetas_por_orden_or_numero_envio
        opts = {
          "idOrdenRetiro" => opts[:id_orden_retiro],
          "nroEnvio" => opts[:nro_envio],
          "logisticaInversa" => opts.fetch(:logistica_inversa, FALSE_STRING).to_s
        }
        response = client.call(method, message: opts)
        parse_result(response, method)
      rescue Savon::SOAPFault => error
        msg = "Oca WS responded with:\n#{error.http.code}\n#{error}"
        raise Oca::Errors::BadRequest.new(msg)
      end
    end
  end
end
