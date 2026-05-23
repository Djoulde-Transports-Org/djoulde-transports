# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Users::Me do
  subject(:do_request) { get "/api/v1/me", headers: headers }

  let(:headers)  { {} }
  let(:password) { "correct horse battery staple" }
  let(:user)     { User.create!(email: "u@example.com", password: password) }
  let(:oauth_app) do
    OauthApplication.create!(name: "spa", redirect_uri: "https://example.com/cb", owner: user)
  end
  let(:token) do
    Doorkeeper::AccessToken.create!(application_id: oauth_app.id, resource_owner_id: user.id, scopes: "default")
  end

  it "returns 401 without a token" do
    do_request
    expect(response).to have_http_status(:unauthorized)
  end

  context "with a valid token whose app is owned by the user" do
    let(:headers) { {"Authorization" => "Bearer #{token.token}"} }

    before do
      user.add_role(:super_admin)
      do_request
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns the user's id" do
      expect(response.parsed_body["id"]).to eq(user.id)
    end

    it "returns the user's roles" do
      expect(response.parsed_body["roles"]).to include("super_admin")
    end
  end

  context "when the token's application belongs to a different user" do
    let(:other_user) { User.create!(email: "other@example.com", password: password) }
    let(:other_app) do
      OauthApplication.create!(name: "other", redirect_uri: "https://other.example.com/cb", owner: other_user)
    end
    let(:wrong_token) do
      Doorkeeper::AccessToken.create!(application_id: other_app.id, resource_owner_id: user.id, scopes: "default")
    end
    let(:headers) { {"Authorization" => "Bearer #{wrong_token.token}"} }

    it "returns 401" do
      do_request
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user has been discarded after token issuance" do
    let(:headers) { {"Authorization" => "Bearer #{token.token}"} }

    it "returns 401" do
      token
      user.discard
      do_request
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
