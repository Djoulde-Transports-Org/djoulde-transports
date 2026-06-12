# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingStatements::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/billing_statements#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:month)        { Time.zone.today.prev_month.beginning_of_month }
  let!(:statement)   { BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}") }

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

    it "returns kept statements" do
      expect(response.parsed_body.pluck("id")).to include(statement.id)
    end
  end

  context "when a statement is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      statement.discard
      do_request
    end

    it "excludes discarded statements" do
      expect(response.parsed_body.pluck("id")).not_to include(statement.id)
    end
  end

  context "when filtering by status" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {status: "issued"} }

    before { do_request }

    it "returns only statements with that status" do
      expect(response.parsed_body.pluck("id")).not_to include(statement.id)
    end
  end

  context "when the status value is invalid" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {status: "nope"} }

    before { do_request }

    it "returns 422" do
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
