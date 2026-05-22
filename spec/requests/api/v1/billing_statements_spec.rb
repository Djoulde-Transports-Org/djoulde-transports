# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/billing_statements", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:month) { Time.zone.today.prev_month.beginning_of_month }
  let(:statement) { BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}") }

  describe "GET /api/v1/billing_statements" do
    it "returns kept statements" do
      statement
      get "/api/v1/billing_statements", headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).to include(statement.id)
    end
  end

  describe "PATCH /api/v1/billing_statements/:id/issue" do
    it "moves the statement from draft to issued" do
      patch "/api/v1/billing_statements/#{statement.id}/issue",
        params: {issued_on: (month.next_month + 2.days).to_s},
        headers: bearer_headers(admin_token)
      expect(statement.reload.status).to eq("issued")
    end
  end

  describe "PATCH /api/v1/billing_statements/:id/mark_paid" do
    it "moves an issued statement to paid" do
      statement.update!(status: :issued, issued_on: month.next_month + 1.day)
      patch "/api/v1/billing_statements/#{statement.id}/mark_paid",
        headers: bearer_headers(admin_token)
      expect(statement.reload.status).to eq("paid")
    end
  end

  describe "DELETE /api/v1/billing_statements/:id" do
    it "discards the statement when no kept line items exist" do
      delete "/api/v1/billing_statements/#{statement.id}", headers: bearer_headers(admin_token)
      expect(statement.reload.discarded?).to be true
    end

    it "returns 422 when kept line items exist" do
      truck = build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}")
      route = Route.create!(origin: "A", destination: "B", rate: 1000)
      trip  = Trip.create!(truck: truck, route: route, actual_start_at: month + 10.days)
      DeliveryNote.create!(trip: trip, number: "DN-X", quantity_gasoline_liters: 5, quantity_diesel_liters: 0)
      BillingLineItem.from_trip(trip, billing_statement: statement).save!

      delete "/api/v1/billing_statements/#{statement.id}", headers: bearer_headers(admin_token)
      expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
    end
  end
end
