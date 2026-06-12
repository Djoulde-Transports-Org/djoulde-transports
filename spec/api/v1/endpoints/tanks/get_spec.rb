# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Tanks::Get do
  subject(:do_request) { get "/api/v1/tanks/#{tank_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) { Truck.create!(plate_number: "H-#{SecureRandom.hex(3)}") }
  let(:tank) do
    Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity: 30_000)
  end
  let(:tank_id) { tank.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept tank" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the tank id" do
        expect(response.parsed_body["id"]).to eq(tank.id)
      end

      it "returns the tank plate_number" do
        expect(response.parsed_body["plate_number"]).to eq(tank.plate_number)
      end
    end

    context "for a discarded tank" do
      before do
        tank.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Tank not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Tank not found.")
      end
    end

    context "for a non-existent id" do
      let(:tank_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Tank not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Tank not found.")
      end
    end
  end
end
