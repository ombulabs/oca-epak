RSpec.describe Oca::Oep::Client do
  let(:username) { "hey@you.com" }
  let(:password) { "123456" }

  subject { Oca::Oep::Client.new(username, password) }

  describe "#get_html_de_etiquetas_por_orden_or_numero_envio" do
    let(:real_order) { 21132466 }
    let(:fake_order) { 123_000_000 }
    it "generates the html of a delivery" do
      VCR.use_cassette("existing_delivery_html") do
        result = subject.get_html_de_etiquetas_por_orden_or_numero_envio(
          id_orden_retiro: real_order
        )

        expect(result).to be
        expect(result).to include "Av Siempreviva 1234"
        expect(result).to include "imagenBarCode"
        expect(result).to include "NRO. ORDEN DE RETIRO"
      end
    end

    it "doesn't generate the html of a delivery for a non-existing order" do
      VCR.use_cassette("non_existing_delivery_html") do
        result = subject.get_html_de_etiquetas_por_orden_or_numero_envio(
          id_orden_retiro: fake_order
        )

        expect(result).to be
        expect(result).not_to include "Av Siempreviva 1234"
        expect(result).not_to include "imagenBarCode"
        expect(result).not_to include "NRO. ORDEN DE RETIRO"
      end
    end
  end

  describe "#get_pdf_de_etiquetas_por_orden_or_numero_envio" do
    let(:real_order) { 21132466 }
    let(:fake_order) { 1000 }

    it "generates the PDF of a delivery" do
      VCR.use_cassette("existing_delivery_pdf") do
        result = subject.get_pdf_de_etiquetas_por_orden_or_numero_envio(
          id_orden_retiro: real_order
        )

        expect(result).to be
        expect(Base64.decode64(result)[0,4]).to eq("%PDF")
      end
    end

    it "raises when attempt to generates the PDF of a delivery for a non-existing order" do
      VCR.use_cassette("non_existing_delivery_pdf") do
        expect do
          subject.get_pdf_de_etiquetas_por_orden_or_numero_envio(
            id_orden_retiro: fake_order
          )
        end.to raise_exception(Oca::Errors::BadRequest)
      end
    end
  end
end
