# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/billing_line_items", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:month)     { Time.zone.today.prev_month.beginning_of_month }
  let(:statement) { BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}") }
  let(:truck)     { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route)     { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip)     { Trip.create!(truck: truck, route: route, actual_start_at: month + 5.days) }
  let(:line_item) do
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                         quantity_gasoline_liters: 10, quantity_diesel_liters: 0)
    BillingLineItem.from_trip(trip, billing_statement: statement).tap(&:save!)
  end

  describe "GET /api/v1/billing_line_items" do
    it "filters by billing_statement_id" do
      line_item
      get "/api/v1/billing_line_items",
        params: {billing_statement_id: statement.id},
        headers: bearer_headers(viewer_token)
      expect(response.parsed_body.pluck("id")).to contain_exactly(line_item.id)
    end
  end

  describe "POST /api/v1/billing_line_items" do
    it "is rejected with 405 method not allowed" do
      post "/api/v1/billing_line_items", params: {}, headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:method_not_allowed)
    end
  end
end
