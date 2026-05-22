# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/routes", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:route) { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }

  describe "GET /api/v1/routes" do
    it "returns 401 without a token" do
      get "/api/v1/routes"
      expect(response).to have_http_status(:unauthorized)
    end

    it "excludes discarded routes" do
      route.discard
      get "/api/v1/routes", headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).not_to include(route.id)
    end
  end

  describe "POST /api/v1/routes" do
    it "creates a route for admin users" do
      expect {
        post "/api/v1/routes",
          params: {origin: "Kankan", destination: "Nzerekore", rate: 2000},
          headers: bearer_headers(admin_token)
      }.to change { Route.count }.by(1)
    end

    it "returns 403 for non-admin users" do
      post "/api/v1/routes",
        params: {origin: "X", destination: "Y", rate: 100},
        headers: bearer_headers(viewer_token)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/routes/:id" do
    it "updates the rate for admin users" do
      patch "/api/v1/routes/#{route.id}",
        params: {rate: 1800},
        headers: bearer_headers(admin_token)
      expect(route.reload.rate).to eq(1800)
    end
  end

  describe "DELETE /api/v1/routes/:id" do
    it "discards the route when no kept trips exist" do
      delete "/api/v1/routes/#{route.id}", headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 422 when kept trips still reference the route" do
      build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}")
      truck = Truck.last
      Trip.create!(truck: truck, route: route)
      delete "/api/v1/routes/#{route.id}", headers: bearer_headers(admin_token)
      expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
    end
  end
end
