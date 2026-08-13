# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingStatements::MarkPaid do
  subject(:do_request) do
    patch "/api/v1/billing_statements/#{statement_id}/mark_paid", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:month)        { Time.zone.today.prev_month.beginning_of_month }
  let(:statement) do
    BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}",
                             status: :issued, issued_on: month.next_month + 1.day)
  end
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

    context "with an issued statement" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "flips the status to paid" do
        expect(statement.reload.status).to eq("paid")
      end

      it "stamps paid_on with today by default" do
        expect(statement.reload.paid_on).to eq(Time.zone.today)
      end
    end

    context "with an explicit paid_on" do
      let(:params) { {paid_on: (month.next_month + 5.days).to_s} }

      before { do_request }

      it "uses the supplied date" do
        expect(statement.reload.paid_on.to_s).to eq((month.next_month + 5.days).to_s)
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
  end
end
