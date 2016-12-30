module Oca
  class Logger
    attr_reader :logger_options

    # Receives a hash with keys `log`, `pretty_print_xml`, `log_level` and
    # `logger`.
    # `log_level` can be :info, :debug, :warn, :error or :fatal
    #
    # @param opts [Hash]
    # @option opts [Boolean] :log
    # @option opts [Boolean] :pretty_print_xml
    # @option opts [Symbol] :log_level
    # @option opts [Logger] :logger
    def initialize(opts = {})
      @logger_options = {}
      @logger_options[:log] = opts[:log] || false
      @logger_options[:pretty_print_xml] = opts[:pretty_print_xml] || false
      @logger_options[:log_level] = opts[:log_level] || :info
      @logger_options[:logger] = opts[:logger] if opts[:logger]
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
