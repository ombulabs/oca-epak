RSpec.describe Oca::Epak::PickupData do
  let(:account_number) { "152480/000" }
  let(:pickup) do
    { "calle"=>"Gorriti", "numero"=>"5887", "piso"=>"",
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
          "calle"=>"Gorriti", "numero"=>"5887", "piso"=>"",
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
    let(:expected_result) do
      <<-XML
<?xml version="1.0" encoding="iso-8859-1" standalone="yes"?>
<ROWS>
	<cabecera ver="1.0" nrocuenta="152480/000" />
	<retiro calle="Gorriti" nro="5887" piso="" depto="" cp="1414" localidad="Capital Federal" provincia="Buenos Aires" contacto="Mauro Otonelli" email="mauro@ombushop.com" solicitante="Mauro Otonelli" observaciones="" centrocosto="0" />
	<envios>
		<envio idoperativa="259563" nroremito="R46363463">
			<destinatario apellido="Tagwerker" nombre="Ernesto" calle="Gorriti" nro="5887" piso="" depto="" cp="1414" localidad="Capital Federal" provincia="Buenos Aires" telefono="34534543" email="ernesto@ombulabs.com" idci="0" celular=""/>
			<paquetes>
				<paquete alto="10" ancho="17" largo="21" peso="1" valor="123" cant="1"/>
			</paquetes>
		</envio>
	</envios>
</ROWS>
      XML
    end

    it "generates the XML according to the documentation" do
      expect(subject.to_xml).to eql(expected_result)
    end
  end
end
