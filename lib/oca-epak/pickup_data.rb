module Oca
  class Epak::PickupData

    attr_accessor :account_number, :pickup, :shipments

    # Creates a Pickup Data object for creating a pickup order in OCA.
    #
    # @param [Hash] opts
    # @option [String] :account_number Account Number (SAP)
    # @option [Hash] :pickup Pickup Hash
    # @option [Array<Hash>] :shipments Shipments Hash
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
        path_to_xml = File.expand_path("../retiro.xml.erb", __FILE__)
        ERB.new(File.read(path_to_xml), nil, "-")
      end
  end
end
