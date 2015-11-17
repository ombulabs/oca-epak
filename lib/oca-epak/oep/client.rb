module Oca
  module Oep
    class Client < BaseClient
      def initialize(username, password)
        super
        wsdl_url = "#{BASE_WSDL_URL}/oep_tracking/Oep_Track.asmx?wsdl"
        @client = Savon.client(wsdl: wsdl_url)
      end

      # Returns the HTML for a label
      #
      # @param opts
      # @option id_orden_retiro [Integer]
      # @option nro_envio [String]
      # @return [String] HTML
      def get_html_de_etiquetas_por_orden_or_numero_envio(opts = {})
        method = :get_html_de_etiquetas_por_orden_or_numero_envio
        opts = { "idOrdenRetiro" => opts[:id_orden_retiro],
                 "nroEnvio" => opts[:nro_envio] }
        response = client.call(method, message: opts)
        parse_result(response, method)
      end
    end
  end
end
