# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trips::Update do
  subject(:do_request) do
    patch "/api/v1/trips/#{trip_id}/update", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {status: "in_progress"} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route)        { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }
  let(:trip)         { Trip.create!(truck: truck, route: route) }
  let(:trip_id)      { trip.id }

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

    context "with a kept trip" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the trip status" do
        expect(trip.reload.status).to eq("in_progress")
      end

      it "returns the updated status" do
        expect(response.parsed_body["status"]).to eq("in_progress")
      end
    end

    context "with a discarded trip" do
      before do
        trip.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Trip not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Trip not found.")
      end
    end

    context "with a non-existent id" do
      let(:trip_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an invalid status value" do
      let(:params) { {status: "nope"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
