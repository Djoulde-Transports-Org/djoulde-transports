# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/trucks", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:truck) do
    Truck.create!(plate_number: "AB-#{SecureRandom.hex(3)}", make: "Volvo", model: "FH", year: 2020)
  end

  describe "GET /api/v1/trucks" do
    it "returns 401 without a token" do
      get "/api/v1/trucks"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns kept trucks for authenticated users" do
      truck
      get "/api/v1/trucks", headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).to include(truck.id)
    end

    it "excludes discarded trucks from the index" do
      truck.discard
      get "/api/v1/trucks", headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).not_to include(truck.id)
    end
  end

  describe "GET /api/v1/trucks/:id" do
    it "returns 404 when the truck is discarded" do
      truck.discard
      get "/api/v1/trucks/#{truck.id}", headers: bearer_headers(viewer_token)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 200 for a kept truck" do
      get "/api/v1/trucks/#{truck.id}", headers: bearer_headers(viewer_token)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/trucks" do
    let(:payload) do
      {
        plate_number: "NEW-#{SecureRandom.hex(2)}",
        vin:          "VIN-#{SecureRandom.hex(4)}",
        make:         "Volvo",
        model:        "FH",
        year:         2022,
      }
    end

    it "returns 403 for non-admin users" do
      post "/api/v1/trucks", params: payload, headers: bearer_headers(viewer_token)
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end

    it "creates a truck for admin users" do
      expect {
        post "/api/v1/trucks", params: payload, headers: bearer_headers(admin_token)
      }.to change { Truck.count }.by(1)
    end

    it "returns 422 when required params are missing" do
      post "/api/v1/trucks", params: {plate_number: ""}, headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/trucks/:id" do
    it "updates the truck for admin users" do
      patch "/api/v1/trucks/#{truck.id}",
        params: {make: "Scania"},
        headers: bearer_headers(admin_token)
      expect(truck.reload.make).to eq("Scania")
    end
  end

  describe "DELETE /api/v1/trucks/:id" do
    it "returns 204 and discards the truck" do
      Current.user = admin
      delete "/api/v1/trucks/#{truck.id}", headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:no_content)
    end

    it "stamps discarded_by on the truck" do
      Current.user = admin
      delete "/api/v1/trucks/#{truck.id}", headers: bearer_headers(admin_token)
      expect(truck.reload.discarded_by_id).to eq(admin.id)
    end

    it "returns 403 for non-admin callers" do
      delete "/api/v1/trucks/#{truck.id}", headers: bearer_headers(viewer_token)
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end
  end
end
