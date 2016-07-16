RSpec.describe Oca::Epak::PickupData do
  let(:account_number) { "152480/000" }
  let(:pickup) do
    { "calle"=>"Av Siempreviva", "numero"=>"1234", "piso"=>"",
      "departamento"=>"", "cp"=>"1414", "localidad"=>"Capital Federal",
      "provincia"=>"Buenos Aires", "solicitante"=>"Mauro Otonelli",
      "email"=>"mauro@ombushop.com", "observaciones"=>"" }
  end
  let(:shipments) do
    [
      {
        "id_operativa"=>"259563", "numero_remito"=>"R46363463",
        "destinatario"=> {
          "apellido"=>"Tagwerker", "nombre"=>"Ernesto",
          "calle"=>"Av Siempreviva", "numero"=>"1234", "piso"=>"",
          "departamento"=>"", "cp"=>"1414", "localidad"=>"Capital Federal",
          "provincia"=>"Buenos Aires", "telefono"=>"34534543",
          "email"=>"ernesto@ombulabs.com"
        }, "paquetes"=> [
          {
            "alto"=>"10", "ancho"=>"17", "largo"=>"21", "peso"=>"1",
            "valor_declarado"=>"123", "cantidad"=>"1"
          }
        ]
      }
    ]
  end
  let(:opts) do
    { account_number: account_number, pickup: pickup, shipments: shipments }
  end

  subject { Oca::Epak::PickupData.new(opts) }

  describe "#to_xml" do
    let(:pickup_data_path) { "spec/support/pickup_data_sample.xml" }
    let(:expected_result) { File.open(pickup_data_path).read }

    it "generates the XML according to the documentation" do
      expect(subject.to_xml).to eql(expected_result)
    end
  end
end
