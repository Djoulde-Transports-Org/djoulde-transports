# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Routes::Delete do
  subject(:do_request) { delete "/api/v1/routes/#{route_id}/delete", headers: headers }

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:route)        { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }
  let(:route_id)     { route.id }

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

    context "with a kept route" do
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
        expect(response.parsed_body["message"]).to eq("Route has been successfully deleted.")
      end

      it "discards the route" do
        expect(route.reload).to be_discarded
      end

      it "stamps discarded_by on the route" do
        expect(route.reload.discarded_by_id).to eq(admin.id)
      end
    end

    context "when kept trips still reference the route" do
      before do
        build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}")
        Trip.create!(truck: Truck.last, route: route)
        do_request
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the has_dependents error code" do
        expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
      end

      it "does not discard the route" do
        expect(route.reload).not_to be_discarded
      end
    end

    context "with a discarded route" do
      before do
        route.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Route not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Route not found.")
      end
    end

    context "with a non-existent id" do
      let(:route_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
