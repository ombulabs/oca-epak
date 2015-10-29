RSpec.describe Oca do
  context "authenticating a user" do
    let(:username) { "hey@you.com" }
    let(:password) { "123456" }
    let(:credentials) { { "usr" => username, "psw" => password } }
    let(:exception) { Savon::SOAPFault.new("", "") }
    let(:oca) { Oca.new }

    it "returns true if the user has valid credentials" do
      allow(oca.client).to(
        receive(:call).with(:generar_consolidacion_de_ordenes_de_retiro,
          message: credentials)).and_raise(exception)

      expect(oca.check_credentials(username, password)).to be_truthy
    end

    it "returns false if the user has invalid credentials" do
      allow(oca.client).to(
        receive(:call).with(:generar_consolidacion_de_ordenes_de_retiro,
          message: credentials)).and_return({})

      expect(oca.check_credentials(username, password)).to be_falsey
    end
  end

  context "checking an operation type exists" do
    let(:cuit) { "30-99999999-7" }
    let(:operation_type) { "77790" }
    let(:exception) { NoMethodError }
    let(:oca) { Oca.new }

    it "returns true if the operation type exists" do
      VCR.use_cassette("get_shipping_rates") do
        expect(oca.check_operation(cuit, operation_type)).to be_truthy
      end
    end

    it "returns false if the operation type doesn't exist" do
      allow(oca).to(receive(:get_shipping_rates)).and_raise(exception)

      expect(oca.check_operation(cuit, operation_type)).to be_falsey
    end
  end

  context "getting shipping rates" do
    let(:cuit) { "30-99999999-7" }
    let(:weight) { "50" }
    let(:volume) { "0.027" }
    let(:origin_zip_code) { "1646" }
    let(:destination_zip_code) { "2000" }
    let(:package_quantity) { "1" }
    let(:operation_type) { "77790" }
    let(:oca) { Oca.new }

    it "returns the shipping price and estimated date" do
      opts = { wt: weight, vol: volume, origin: origin_zip_code,
        destination: destination_zip_code, qty: package_quantity, cuit: cuit,
        op: operation_type }

      VCR.use_cassette("get_shipping_rates") do
        response = oca.get_shipping_rates(opts)
        expect(response).to be
        expect(response[:precio]).to eql("328.9000")
        expect(response[:ambito]).to eql("Regional")
        expect(response[:plazo_entrega]).to eql("3")
      end
    end
  end
end
