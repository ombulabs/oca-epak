RSpec.describe Oca do
  context "authenticating a user" do
    let(:username) { "hey@you.com" }
    let(:password) { "123456" }
    let(:credentials) { { "usr" => username, "psw" => password } }
    let(:exception) { Savon::SOAPFault.new("", "") }

    before do
      @oca = Oca.new
    end

    it "returns true if the user has valid credentials" do
      allow(@oca.client).to(
        receive(:call).with(:generar_consolidacion_de_ordenes_de_retiro,
          message: credentials)).and_raise(exception)

      expect(@oca.check_credentials(username, password)).to be_truthy
    end

    it "returns false if the user has invalid credentials" do
      allow(@oca.client).to(
        receive(:call).with(:generar_consolidacion_de_ordenes_de_retiro,
          message: credentials)).and_return({})

      expect(@oca.check_credentials(username, password)).to be_falsey
    end
  end
end
