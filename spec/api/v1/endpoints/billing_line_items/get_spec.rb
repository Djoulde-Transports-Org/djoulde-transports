# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingLineItems::Get do
  subject(:do_request) { get "/api/v1/billing_line_items/#{line_item_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:month)        { Time.zone.today.prev_month.beginning_of_month }
  let(:statement)    { BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}") }
  let(:truck)        { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route)        { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip)         { Trip.create!(truck: truck, route: route, actual_start_at: month + 5.days) }
  let(:line_item) do
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                         gasoline_quantity: 10, diesel_quantity: 0)
    BillingLineItem.from_trip(trip, billing_statement: statement).tap(&:save!)
  end
  let(:line_item_id) { line_item.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept line item" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the line item id" do
        expect(response.parsed_body["id"]).to eq(line_item.id)
      end

      it "returns the statement id" do
        expect(response.parsed_body["billing_statement_id"]).to eq(statement.id)
      end
    end

    context "for a discarded line item" do
      before do
        line_item.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Billing line item not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Billing line item not found.")
      end
    end

    context "for a non-existent id" do
      let(:line_item_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
