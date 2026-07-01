# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Users::Session::Delete do
  subject(:do_request) { delete "/api/v1/sessions", headers: headers }

  let(:headers)      { {} }
  let(:user_setup)   { auth_setup }
  let(:user_token)   { user_setup[1] }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(user_token) }

    before { do_request }

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns success: true" do
      expect(response.parsed_body["success"]).to be true
    end

    it "revokes the token" do
      expect(user_token.reload.revoked?).to be true
    end
  end

  context "with an already-revoked token" do
    let(:headers) { bearer_headers(user_token) }

    before do
      user_token.revoke
      do_request
    end

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
