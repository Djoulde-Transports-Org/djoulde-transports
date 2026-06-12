# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingLineItems::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/billing_line_items#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:month)        { Time.zone.today.prev_month.beginning_of_month }
  let(:statement)    { BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}") }
  let(:truck)        { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route)        { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip)         { Trip.create!(truck: truck, route: route, actual_start_at: month + 5.days) }
  let!(:line_item) do
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                         gasoline_quantity: 10, diesel_quantity: 0)
    BillingLineItem.from_trip(trip, billing_statement: statement).tap(&:save!)
  end

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns kept line items" do
      expect(response.parsed_body.pluck("id")).to include(line_item.id)
    end
  end

  context "when a line item is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      line_item.discard
      do_request
    end

    it "excludes discarded line items" do
      expect(response.parsed_body.pluck("id")).not_to include(line_item.id)
    end
  end

  context "when filtering by billing_statement_id" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {billing_statement_id: statement.id} }

    before { do_request }

    it "returns only line items for that statement" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(line_item.id)
    end
  end

  context "when filtering by trip_id" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {trip_id: trip.id} }

    before { do_request }

    it "returns only line items for that trip" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(line_item.id)
    end
  end

  context "when posting to the collection" do
    it "is rejected with 405 method not allowed" do
      post "/api/v1/billing_line_items", params: {}, headers: bearer_headers(viewer_token)
      expect(response).to have_http_status(:method_not_allowed)
    end
  end
end
