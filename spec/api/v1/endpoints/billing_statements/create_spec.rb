# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingStatements::Create do
  subject(:do_request) do
    post "/api/v1/billing_statements/create", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:month)        { Time.zone.today.prev_month.beginning_of_month }
  let(:params)       { {month: month.to_s} }

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

    it "creates a statement" do
      expect { do_request }.to change { BillingStatement.count }.by(1)
    end

    context "when the request is successful" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the covered month" do
        expect(response.parsed_body["month"]).to eq(month.to_s)
      end

      it "auto-generates a number" do
        expect(response.parsed_body["number"]).to be_present
      end
    end

    context "with an explicit number" do
      let(:params) { {month: month.to_s, number: "STMT-EXPLICIT"} }

      before { do_request }

      it "uses the supplied number" do
        expect(response.parsed_body["number"]).to eq("STMT-EXPLICIT")
      end
    end

    context "with a missing month" do
      let(:params) { {} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "when a statement already exists for that month" do
      before do
        BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}")
        do_request
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
