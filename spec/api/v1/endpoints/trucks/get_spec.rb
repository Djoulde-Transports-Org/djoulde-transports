# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::Get do
  subject(:do_request) { get "/api/v1/trucks/#{truck_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) do
    Truck.create!(plate_number: "AB-#{SecureRandom.hex(3)}", make: "Volvo", model: "FH", year: 2020)
  end
  let(:truck_id) { truck.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept truck" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the truck id" do
        expect(response.parsed_body["id"]).to eq(truck.id)
      end

      it "returns the truck plate_number" do
        expect(response.parsed_body["plate_number"]).to eq(truck.plate_number)
      end
    end

    context "for a discarded truck" do
      before do
        truck.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Truck not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Truck not found.")
      end
    end

    context "for a non-existent id" do
      let(:truck_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Truck not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Truck not found.")
      end
    end
  end
end
