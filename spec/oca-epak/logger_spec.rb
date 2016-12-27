RSpec.describe Oca::Logger do
  subject { Oca::Logger }
  let(:default_options) do
    { log: false, pretty_print_xml: false, log_level: :info }
  end
  let(:custom_options) { { log: true, log_level: :debug, logger: custom_logger } }
  let(:custom_logger) { double(:logger) }

  after { Oca::Logger.options = default_options }

  describe ".options" do
    context "no logger has been defined before" do
      it "creates a logger with default options" do
        expect(subject.options).to eql(default_options)
      end
    end

    context "a logger has already been defined" do
      before { subject.options = custom_options }

      it "returns the already defined logger" do
        expect(subject.options).to eql(default_options.merge(custom_options))
      end
    end
  end

  describe ".options=" do
    let(:custom_options) { { log: true } }

    it "creates a new logger with the passed options" do
      subject.options = custom_options
      expect(subject.options).to eql(default_options.merge(custom_options))
    end
  end
end
