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

  describe "#get_operation_codes" do
    context "valid user + password" do
      let(:expected_result) do
        [{ :id_operativa=>"259563",
          :descripcion=>"259563 - ENVIOS DE SUCURSAL A SUCURSAL",
          :con_volumen=>false,
          :con_valor_declarado=>false,
          :a_sucursal=>false,
          :"@diffgr:id"=>"Table1",
          :"@msdata:row_order"=>"0" }]
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

  describe "#get_shipping_rate" do
    let(:weight) { "50" }
    let(:volume) { "0.027" }
    let(:origin_zip_code) { "1646" }
    let(:destination_zip_code) { "2000" }
    let(:package_quantity) { "1" }
    let(:operation_code) { "77790" }
    let(:declared_value) { "100" }

    it "returns the shipping price and estimated days until delivery" do
      opts = { total_weight: weight, total_volume: volume,
        origin_zip_code: origin_zip_code,
        destination_zip_code: destination_zip_code,
        declared_value: declared_value, package_quantity: package_quantity,
        cuit: cuit, operation_code: operation_code }

      VCR.use_cassette("get_shipping_rate") do
        response = subject.get_shipping_rate(opts)
        expect(response).to be_a Hash
        expect(response[:precio]).to eql("396.6900")
        expect(response[:ambito]).to eql("Nacional 1")
        expect(response[:plazo_entrega]).to eql("9")
      end
    end
  end

  describe "#create_pickup_order" do
    let(:pickup_data_path) { "spec/support/pickup_data_sample.xml" }
    let(:pickup_xml) { File.open(pickup_data_path).read }
    let(:pickup_data) { spy(Oca::Epak::PickupData.new) }

    before { allow(pickup_data).to receive(:to_xml).and_return(pickup_xml) }

    it "creates a pickup order in Oca's server" do
      VCR.use_cassette("create_pickup_order") do
        response = subject.create_pickup_order(pickup_data: pickup_data)
        expect(response).to be
      end
    end
  end

  describe "#taxation_centers_with_services" do
    let(:first_center) do
      {
        :id_centro_imposicion=>"2",
        :sigla=>"ADG",
        :sucursal=>"LUIS GUILLON                  ",
        :calle=>"BOULEVARD BS. AS.             ",
        :numero=>"1459 ",
        :torre=>nil,
        :piso=>nil,
        :depto=>nil,
        :localidad=>"LUIS GUILLON             ",
        :codigo_postal=>"1838    ",
        :provincia=>"BUENOS AIRES                  ",
        :telefono=>"4367-5729      ",
        :latitud=>"-34.80982941",
        :longitud=>"-58.44765759",
        :tipo_agencia=>"Sucursal OCA",
        :horario_atencion=>"Lun a Vie 8:30 a 18 hs. ",
        :sucursal_oca=>"ADG",
        :servicios => {
          :servicio=>[
            {
              :id_tipo_servicio=>"1",
              :servicio_desc=>"Admisión de paquetes"
            },
            {
              :id_tipo_servicio=>"2",
              :servicio_desc=>"Entrega de paquetes"
            },
            {
              :id_tipo_servicio=>"3",
              :servicio_desc=>"Venta Estampillas"
            }
          ]
        }
      }
    end

    it "returns the list of taxation centers with services" do
      VCR.use_cassette("taxation_centers_with_services") do
        response = subject.taxation_centers_with_services
        expect(response).to be_a Hash
        expect(response[:centros_de_imposicion][:centro].first).to eq first_center
      end
    end
  end

  describe "#taxation_centers_with_services_by_zipcode" do
    let(:first_center) do
      {
        :id_centro_imposicion=>"2",
        :sigla=>"ADG",
        :sucursal=>"LUIS GUILLON                  ",
        :calle=>"BOULEVARD BS. AS.             ",
        :numero=>"1459 ",
        :torre=>nil,
        :piso=>nil,
        :depto=>nil,
        :localidad=>"LUIS GUILLON             ",
        :codigo_postal=>"1838    ",
        :provincia=>"BUENOS AIRES                  ",
        :telefono=>"4367-5729      ",
        :latitud=>"-34.80982941",
        :longitud=>"-58.44765759",
        :tipo_agencia=>"Sucursal OCA",
        :horario_atencion=>"Lun a Vie 8:30 a 18 hs. ",
        :sucursal_oca=>"ADG",
        :servicios => {
          :servicio=>[
            {
              :id_tipo_servicio=>"1",
              :servicio_desc=>"Admisión de paquetes"
            },
            {
              :id_tipo_servicio=>"2",
              :servicio_desc=>"Entrega de paquetes"
            },
            {
              :id_tipo_servicio=>"3",
              :servicio_desc=>"Venta Estampillas"
            }
          ]
        }
      }
    end

    it "returns the list of taxation centers with services by zipcode" do
      VCR.use_cassette("taxation_centers_with_services_by_zipcode") do
        response = subject.taxation_centers_with_services_by_zipcode(codigo_postal: "1838")
        expect(response).to be_a Hash
        expect(response[:centros_de_imposicion][:centro].first).to eq first_center
      end
    end
  end

  describe "#tracking_object" do
    it "returns the history of the object" do
      expected_response = "[{\"numero_envio\":\"1217400000000082171\",\"descripcion_motivo\":\"Sin Motivo\",\"desdcripcion_estado\":\"En proceso de Admision - Suc: ZAPALA\",\"suc\":\"Suc: ZAPALA\",\"fecha\":\"2016-12-13T00:00:00-03:00\",\"@diffgr:id\":\"Table1\",\"@msdata:row_order\":\"0\"},{\"numero_envio\":\"1217400000000082171\",\"descripcion_motivo\":\"Sin Motivo\",\"desdcripcion_estado\":\"En Espera de Retiro por Sucursal - Suc: PLANTA VELEZ SARSFIELD\",\"suc\":\"Suc: PLANTA VELEZ SARSFIELD\",\"fecha\":\"2017-01-13T00:00:00-03:00\",\"@diffgr:id\":\"Table2\",\"@msdata:row_order\":\"1\"},{\"numero_envio\":\"1217400000000082171\",\"descripcion_motivo\":\"Sin Motivo\",\"desdcripcion_estado\":\"Entregado - Suc: PLANTA VELEZ SARSFIELD\",\"suc\":\"Suc: PLANTA VELEZ SARSFIELD\",\"fecha\":\"2017-01-13T00:00:00-03:00\",\"@diffgr:id\":\"Table3\",\"@msdata:row_order\":\"2\"}]"

      VCR.use_cassette("tracking_object") do
        response = subject.tracking_object(pieza: "1217400000000082171", cuit: cuit)
        expect(response).to be_a Hash
        expect(response[:diffgram][:new_data_set][:table].to_json).to eq expected_response
      end
    end

    it "normalizes the CUIT when the number has not mask" do
    	unmasked_cuit = cuit.gsub('-', '')

    	message = {
    		message: {
	    		"Cuit" => cuit,
	        "Pieza" => "1217400000000082171"
        }
    	}

      fake_response = double("Savon::Response", body: { foo: "bar" })

      VCR.use_cassette("tracking_object") do
        allow(subject.client).to receive(:call).and_return(fake_response)
        subject.tracking_object(pieza: "1217400000000082171", cuit: unmasked_cuit)
        expect(subject.client).to have_received(:call).with(:tracking_pieza, message)
      end
    end
  end

  describe "#tracking_object_with_ids" do
    it "returns the history of the object" do
      expected_response = "[{\"numero_envio\":\"1217400000000082171\",\"descripcion_motivo\":\"Sin Motivo\",\"desdcripcion_estado\":\"En proceso de Admision - Suc: ZAPALA\",\"id_estado\":\"57\",\"suc\":\"Suc: ZAPALA\",\"fecha\":\"2016-12-13T00:00:00-03:00\",\"@diffgr:id\":\"Table1\",\"@msdata:row_order\":\"0\"},{\"numero_envio\":\"1217400000000082171\",\"descripcion_motivo\":\"Sin Motivo\",\"desdcripcion_estado\":\"En Espera de Retiro por Sucursal - Suc: PLANTA VELEZ SARSFIELD\",\"id_estado\":\"23\",\"suc\":\"Suc: PLANTA VELEZ SARSFIELD\",\"fecha\":\"2017-01-13T00:00:00-03:00\",\"@diffgr:id\":\"Table2\",\"@msdata:row_order\":\"1\"},{\"numero_envio\":\"1217400000000082171\",\"descripcion_motivo\":\"Sin Motivo\",\"desdcripcion_estado\":\"Entregado - Suc: PLANTA VELEZ SARSFIELD\",\"id_estado\":\"63\",\"suc\":\"Suc: PLANTA VELEZ SARSFIELD\",\"fecha\":\"2017-01-13T00:00:00-03:00\",\"@diffgr:id\":\"Table3\",\"@msdata:row_order\":\"2\"}]"

      VCR.use_cassette("tracking_object_with_ids") do
        response = subject.tracking_object_with_ids(pieza: "1217400000000082171")
        expect(response).to be_a Hash
        expect(response[:diffgram][:new_data_set][:table].to_json).to eq expected_response
      end
    end
  end
end
