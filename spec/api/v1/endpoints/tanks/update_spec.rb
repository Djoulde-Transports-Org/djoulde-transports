# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Tanks::Update do
  subject(:do_request) do
    patch "/api/v1/tanks/#{tank_id}/update", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {make: "Scania"} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) { Truck.create!(plate_number: "H-#{SecureRandom.hex(3)}") }
  let(:tank) do
    Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity_liters: 30_000)
  end
  let(:tank_id) { tank.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user is not an admin" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept tank" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the tank" do
        expect(tank.reload.make).to eq("Scania")
      end

      it "returns the updated make" do
        expect(response.parsed_body["make"]).to eq("Scania")
      end
    end

    context "with a discarded tank" do
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

    context "with a non-existent id" do
      let(:tank_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an out-of-range year" do
      let(:params) { {year: 1800} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with an invalid status value" do
      let(:params) { {status: "wrecked"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
