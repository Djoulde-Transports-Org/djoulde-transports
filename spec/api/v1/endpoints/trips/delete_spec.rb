# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trips::Delete do
  subject(:do_request) { delete "/api/v1/trips/#{trip_id}/delete", headers: headers }

  let(:headers)      { {} }
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

    it "returns the forbidden error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept trip" do
      it "discards the trip" do
        do_request
        expect(trip.reload.discarded?).to be true
      end

      it "returns 200" do
        do_request
        expect(response).to have_http_status(:ok)
      end

      it "returns the success message" do
        do_request
        expect(response.parsed_body["success"]).to be true
      end
    end

    context "when the trip is already on a billing line item" do
      before do
        DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                             quantity_gasoline_liters: 10, quantity_diesel_liters: 0)
        statement = BillingStatement.create!(month: Time.zone.today.beginning_of_month, number: "2026-05")
        BillingLineItem.from_trip(trip, billing_statement: statement).save!
        do_request
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the has_dependents error code" do
        expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
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
    end

    context "with a non-existent id" do
      let(:trip_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
