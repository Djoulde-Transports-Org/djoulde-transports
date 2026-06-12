# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingStatements::Update do
  subject(:do_request) do
    patch "/api/v1/billing_statements/#{statement_id}/update", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {number: "STMT-UPDATED"} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
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
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept statement" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the number" do
        expect(statement.reload.number).to eq("STMT-UPDATED")
      end

      it "returns the updated number" do
        expect(response.parsed_body["number"]).to eq("STMT-UPDATED")
      end
    end

    context "with an issued_on outside the issue window" do
      let(:params) { {issued_on: (month + 2.days).to_s} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
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

      it "returns the 'Billing statement not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Billing statement not found.")
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
