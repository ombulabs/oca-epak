module Oca
  class BaseClient
    attr_reader :client
    attr_accessor :username, :password

    BASE_WSDL_URL = 'http://webservice.oca.com.ar'.freeze

    def initialize(username, password)
      @username = username
      @password = password
    end

    protected

      def parse_result(response, method)
        method_response = "#{method}_response".to_sym
        method_result = "#{method}_result".to_sym
        if body = response.body[method_response]
          body[method_result]
        end
      end

      # @return [Array, nil]
      def parse_results_table(response, method)
        if result = parse_result(response, method)
          if result[:diffgram][:new_data_set]
            table = result[:diffgram][:new_data_set][:table]
            table.is_a?(Hash) ? [table] : table
          else
            raise Oca::Errors::BadRequest.new("Oca WS responded with:\n#{response.body}")
          end
        end
      end
  end
end
