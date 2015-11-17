RSpec.describe Oca::Epak::Client do
  let(:cuit) { "30-99999999-7" }
  let(:username) { "hey@you.com" }
  let(:password) { "123456" }
  let(:invalid_password) { "654321" }

  subject { Oca::Epak::Client.new(username, password) }

  describe "#check_credentials" do
    it "returns true if the user has valid credentials" do
      VCR.use_cassette("check_credentials_are_valid") do
        expect(subject.check_credentials).to be_truthy
      end
    end

    it "returns false if the user has invalid credentials" do
      subject.password = invalid_password

      VCR.use_cassette("check_credentials_are_invalid") do
        expect(subject.check_credentials).to be_falsey
      end
    end
  end

  describe "#check_operation" do
    let(:operation_type) { "77790" }

    it "returns true if the operation type exists" do
      VCR.use_cassette("get_shipping_rates") do
        expect(subject.check_operation(cuit, operation_type)).to be_truthy
      end
    end

    it "returns false if the operation type doesn't exist" do
      VCR.use_cassette("get_shipping_rates_invalid") do
        expect(subject.check_operation(cuit, operation_type)).to be_falsey
      end
    end
  end

  describe "#get_operation_codes" do
    context "valid user + password" do
      let(:expected_result) do
        { :id_operativa=>"259563",
          :descripcion=>"259563 - ENVIOS DE SUCURSAL A SUCURSAL",
          :con_volumen=>false,
          :con_valor_declarado=>false,
          :a_sucursal=>false,
          :"@diffgr:id"=>"Table1",
          :"@msdata:row_order"=>"0" }
      end

      it "returns all the operations available for the user" do
        VCR.use_cassette("get_operation_codes") do
          result = subject.get_operation_codes
          expect(result).to eql(expected_result)
        end
      end
    end

    context "invalid user" do
      it "raises when they attempt to get operation codes" do
        VCR.use_cassette("get_operation_codes_bad_request") do
          expect do
            subject.get_operation_codes
          end.to raise_exception(Oca::Errors::BadRequest)
        end
      end
    end
  end

  describe "#get_shipping_rates" do
    let(:weight) { "50" }
    let(:volume) { "0.027" }
    let(:origin_zip_code) { "1646" }
    let(:destination_zip_code) { "2000" }
    let(:package_quantity) { "1" }
    let(:operation_type) { "77790" }

    it "returns the shipping price and estimated days until delivery" do
      opts = { wt: weight, vol: volume, origin: origin_zip_code,
        destination: destination_zip_code, qty: package_quantity, cuit: cuit,
        op: operation_type }

      VCR.use_cassette("get_shipping_rates") do
        response = subject.get_shipping_rates(opts)
        expect(response).to be
        expect(response[:precio]).to eql("396.6900")
        expect(response[:ambito]).to eql("Nacional 1")
        expect(response[:plazo_entrega]).to eql("9")
      end
    end
  end

  describe "#create_pickup_order" do
    let(:pickup_data_path) { "../../../../fixtures/pickup_data_sample.xml" }
    let(:pickup_xml) do
      File.open(File.expand_path(pickup_data_path, __FILE__)).read
    end
    let(:pickup_data) { spy(Oca::Epak::PickupData.new) }

    before { allow(pickup_data).to receive(:to_xml).and_return(pickup_xml) }

    it "creates a pickup order in Oca's server" do
      VCR.use_cassette("create_pickup_order") do
        repsonse = subject.create_pickup_order(pickup_data: pickup_data)
        expect(response).to be
      end
    end
  end
end
