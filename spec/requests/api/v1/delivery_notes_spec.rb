# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/trips/:trip_id/delivery_note", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:truck) { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip)  { Trip.create!(truck: truck, route: route) }

  describe "POST" do
    it "creates a delivery note nested under the trip" do
      post "/api/v1/trips/#{trip.id}/delivery_note",
        params: {number: "DN-#{SecureRandom.hex(2)}", quantity_gasoline_liters: 5, quantity_diesel_liters: 0},
        headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:created)
    end

    it "returns 404 when the parent trip is discarded" do
      trip.discard
      post "/api/v1/trips/#{trip.id}/delivery_note",
        params: {number: "DN-X"},
        headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET" do
    it "returns the delivery note" do
      DeliveryNote.create!(trip: trip, number: "DN-G", quantity_gasoline_liters: 1, quantity_diesel_liters: 0)
      get "/api/v1/trips/#{trip.id}/delivery_note", headers: bearer_headers(viewer_token)
      expect(response.parsed_body["number"]).to eq("DN-G")
    end

    it "returns 404 when the trip has no delivery note" do
      get "/api/v1/trips/#{trip.id}/delivery_note", headers: bearer_headers(viewer_token)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE" do
    it "discards the delivery note" do
      note = DeliveryNote.create!(trip: trip, number: "DN-D", quantity_gasoline_liters: 1, quantity_diesel_liters: 0)
      delete "/api/v1/trips/#{trip.id}/delivery_note", headers: bearer_headers(admin_token)
      expect(note.reload.discarded?).to be true
    end
  end
end
