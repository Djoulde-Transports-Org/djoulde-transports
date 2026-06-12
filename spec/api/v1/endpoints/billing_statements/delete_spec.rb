# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingStatements::Delete do
  subject(:do_request) { delete "/api/v1/billing_statements/#{statement_id}/delete", headers: headers }

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:month)        { Time.zone.today.prev_month.beginning_of_month }
  let(:statement)    { BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}") }
  let(:statement_id) { statement.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user is not an admin" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "returns the forbidden error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with no kept line items" do
      before do
        Current.user = admin
        do_request
      end

      it "discards the statement" do
        expect(statement.reload.discarded?).to be true
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the success message" do
        expect(response.parsed_body["success"]).to be true
      end
    end

    context "with kept line items" do
      before do
        truck = build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}")
        route = Route.create!(origin: "A", destination: "B", rate: 1000)
        trip  = Trip.create!(truck: truck, route: route, actual_start_at: month + 10.days)
        DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                             gasoline_quantity: 5, diesel_quantity: 0)
        BillingLineItem.from_trip(trip, billing_statement: statement).save!
        do_request
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the has_dependents code" do
        expect(response.parsed_body.dig("error", "code")).to eq("has_dependents")
      end

      it "does not discard the statement" do
        expect(statement.reload.discarded?).to be false
      end
    end

    context "with a discarded statement" do
      before do
        statement.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a non-existent id" do
      let(:statement_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
