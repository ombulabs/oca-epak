module Oca
  module Epak
    class PickupData
      PATH_TO_XML = File.expand_path("../retiro.xml.erb", __FILE__).freeze

      attr_accessor :account_number, :pickup, :shipments

      # Creates a Pickup Data object for creating a pickup order in OCA.
      #
      # @param [Hash] opts
      # @option opts [String] :account_number Account Number (SAP)
      # @option opts [Hash] :pickup Pickup Hash
      # @option opts [Array<Hash>] :shipments Shipments Hash
      def initialize(opts = {})
        self.account_number = opts[:account_number]
        self.pickup = opts[:pickup]
        self.shipments = opts[:shipments]
      end

      def to_xml
        or_template.result(binding)
      end

      private

        def or_template
          ERB.new(File.read(PATH_TO_XML), nil, "-")
        end
    end
  end
end
