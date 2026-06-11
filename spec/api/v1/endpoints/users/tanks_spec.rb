# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/tanks", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:truck) { Truck.create!(plate_number: "H-#{SecureRandom.hex(2)}") }
  let(:tank) do
    Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity_liters: 30_000)
  end

  describe "GET /api/v1/tanks" do
    it "returns 401 without a token" do
      get "/api/v1/tanks"
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists kept tanks" do
      tank
      get "/api/v1/tanks", headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).to include(tank.id)
    end

    it "filters by truck_id" do
      tank
      get "/api/v1/tanks", params: {truck_id: truck.id}, headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).to contain_exactly(tank.id)
    end
  end

  describe "POST /api/v1/tanks" do
    let(:payload) do
      {truck_id: truck.id, plate_number: "TK-#{SecureRandom.hex(2)}", capacity_liters: 28_000}
    end

    it "creates a tank attached to the truck" do
      expect {
        post "/api/v1/tanks/create", params: payload, headers: bearer_headers(admin_token)
      }.to change { Tank.count }.by(1)
    end

    it "returns 403 for non-admin users" do
      post "/api/v1/tanks/create", params: payload, headers: bearer_headers(viewer_token)
      expect(response).to have_http_status(:forbidden)
    end

    it "rejects a second tank on the same truck" do
      Tank.create!(truck: truck, plate_number: "TK-FIRST", capacity_liters: 20_000)
      post "/api/v1/tanks/create", params: payload, headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /api/v1/tanks/:id" do
    it "discards a tank with no kept trips" do
      delete "/api/v1/tanks/#{tank.id}/delete", headers: bearer_headers(admin_token)
      expect(tank.reload.discarded?).to be true
    end

    it "returns 422 when kept trips reference the tank" do
      route = Route.create!(origin: "A", destination: "B", rate: 1000)
      Trip.create!(truck: truck, tank: tank, route: route)
      delete "/api/v1/tanks/#{tank.id}/delete", headers: bearer_headers(admin_token)
      expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
    end
  end

  describe "Trucks::Discard interaction" do
    it "blocks truck discard while a kept tank exists" do
      tank
      delete "/api/v1/trucks/#{truck.id}", headers: bearer_headers(admin_token)
      expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
    end
  end
end
