# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingStatements::Get do
  subject(:do_request) { get "/api/v1/billing_statements/#{statement_id}", headers: headers }

  let(:headers)      { {} }
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

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept statement" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the statement id" do
        expect(response.parsed_body["id"]).to eq(statement.id)
      end

      it "returns the status" do
        expect(response.parsed_body["status"]).to eq("draft")
      end
    end

    context "for a discarded statement" do
      before do
        statement.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Billing statement not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Billing statement not found.")
      end
    end

    context "for a non-existent id" do
      let(:statement_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
