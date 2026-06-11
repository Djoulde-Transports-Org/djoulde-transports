# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/maintenances", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:truck) { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance) { Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :routine) }

  describe "POST /api/v1/maintenances" do
    it "creates a maintenance record" do
      expect {
        post "/api/v1/maintenances",
          params: {truck_id: truck.id, performed_on: Time.zone.today.to_s, kind: "repair", cost: 100},
          headers: bearer_headers(admin_token)
      }.to change { Maintenance.count }.by(1)
    end
  end

  describe "GET /api/v1/maintenances" do
    it "filters by truck_id" do
      maintenance
      get "/api/v1/maintenances",
        params: {truck_id: truck.id},
        headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).to contain_exactly(maintenance.id)
    end
  end

  describe "DELETE /api/v1/maintenances/:id" do
    it "discards the maintenance" do
      delete "/api/v1/maintenances/#{maintenance.id}", headers: bearer_headers(admin_token)
      expect(maintenance.reload.discarded?).to be true
    end
  end
end
