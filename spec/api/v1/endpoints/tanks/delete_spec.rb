# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Tanks::Delete do
  subject(:do_request) { delete "/api/v1/tanks/#{tank_id}/delete", headers: headers }

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
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

  context "when the user is not an admin" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "returns the forbidden error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept tank" do
      before do
        Current.user = admin
        do_request
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns success: true" do
        expect(response.parsed_body["success"]).to be true
      end

      it "returns the success message" do
        expect(response.parsed_body["message"]).to eq("Tank has been successfully deleted.")
      end

      it "discards the tank" do
        expect(tank.reload).to be_discarded
      end

      it "stamps discarded_by on the tank" do
        expect(tank.reload.discarded_by_id).to eq(admin.id)
      end
    end

    context "when kept trips reference the tank" do
      let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }

      before do
        Trip.create!(truck: truck, tank: tank, route: route)
        do_request
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the has_dependents error code" do
        expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
      end

      it "leaves the tank kept" do
        expect(tank.reload).not_to be_discarded
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
  end
end
