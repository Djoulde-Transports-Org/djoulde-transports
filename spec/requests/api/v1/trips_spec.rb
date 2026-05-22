# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/trips", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:truck) { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip)  { Trip.create!(truck: truck, route: route) }

  describe "GET /api/v1/trips" do
    it "returns 401 without a token" do
      get "/api/v1/trips"
      expect(response).to have_http_status(:unauthorized)
    end

    it "filters by truck_id" do
      trip
      other_trip = Trip.create!(truck: build_truck_with_tank(plate: "T-other"), route: route)
      get "/api/v1/trips", params: {truck_id: truck.id}, headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).to contain_exactly(trip.id)
    end
  end

  describe "POST /api/v1/trips" do
    it "creates a trip for admin users" do
      expect {
        post "/api/v1/trips",
          params: {truck_id: truck.id, route_id: route.id, status: "scheduled"},
          headers: bearer_headers(admin_token)
      }.to change { Trip.count }.by(1)
    end
  end

  describe "DELETE /api/v1/trips/:id" do
    it "discards the trip" do
      delete "/api/v1/trips/#{trip.id}", headers: bearer_headers(admin_token)
      expect(trip.reload.discarded?).to be true
    end

    it "returns 422 when the trip already appears on a billing line item" do
      DeliveryNote.create!(trip: trip, number: "DN-1",
                            quantity_gasoline_liters: 10, quantity_diesel_liters: 0)
      statement = BillingStatement.create!(month: Time.zone.today.beginning_of_month, number: "2026-05")
      BillingLineItem.from_trip(trip, billing_statement: statement).save!
      delete "/api/v1/trips/#{trip.id}", headers: bearer_headers(admin_token)
      expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
    end
  end
end
