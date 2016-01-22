RSpec.describe Oca::BaseClient do
  let(:username) { "hey@you.com" }
  let(:password) { "654321" }

  subject { Oca::BaseClient.new(username, password) }

  describe "#parse_results_table" do
    let(:method_name) { :method_name }
    let(:body) do
      {:method_name_response=>
        {:method_name_result=>
          {:diffgram=> {:new_data_set=> {:table=> {:foo=>"bar"} } } }
        }
      }
    end
    let(:invalid_body) { {:foo=>"bar"} }
    let(:oca_response) { double("Savon::Response", body: body) }
    let(:invalid_oca_response) { double("Savon::Response", body: invalid_body) }

    it "returns the contents of the table hash in the Oca response" do
      result = subject.send(:parse_results_table, oca_response, method_name)
      expected_result = [{foo: "bar"}]
      expect(result).to eq(expected_result)
    end

    it "returns nil if the response doesn't contain the expected keys" do
      result = subject.send(:parse_results_table, invalid_oca_response,
        method_name)
      expected_result = nil
      expect(result).to eq(expected_result)
    end
  end
end
