module Oca
  class Logger
    attr_accessor :log, :pretty_print_xml, :log_level

    # Receives a hash with keys `log`, `pretty_print_xml` and `log_level`.
    # `log_level` can be :info, :debug, :warn, :error or :fatal
    #
    # @param opts [Hash]
    # @option opts [Boolean] :log
    # @option opts [Boolean] :pretty_print_xml
    # @option opts [Symbol] :log_level
    def initialize(opts = {})
      @log = opts[:log] || false
      @pretty_print_xml = opts[:pretty_print_xml] || false
      @log_level = opts[:log_level] || :info
    end

    # Returns a hash with the logging options for Savon.
    #
    # @return [Hash]
    def logger_options
      { log: log, pretty_print_xml: pretty_print_xml, log_level: log_level }
    end

    def self.options=(opts = {})
      @logger = Oca::Logger.new(opts)
    end

    def self.options
      @logger ||= Oca::Logger.new
      @logger.logger_options
    end
  end
end
