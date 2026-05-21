# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /api/v1/me", type: :request do
  let(:password) { "correct horse battery staple" }
  let(:user)     { User.create!(email: "u@example.com", password: password) }
  let(:oauth_app) do
    OauthApplication.create!(name: "spa", redirect_uri: "https://example.com/cb", owner: user)
  end
  let(:token) do
    Doorkeeper::AccessToken.create!(application_id: oauth_app.id, resource_owner_id: user.id, scopes: "default")
  end

  def me(token_value = nil)
    headers = token_value ? {"Authorization" => "Bearer #{token_value}"} : {}
    get "/api/v1/me", headers: headers
  end

  it "returns 401 without a token" do
    me
    expect(response).to have_http_status(:unauthorized)
  end

  context "with a valid token whose app is owned by the user" do
    before do
      user.add_role(:super_admin)
      me(token.token)
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
    it "returns 401" do
      other_user = User.create!(email: "other@example.com", password: password)
      other_app  = OauthApplication.create!(name: "other", redirect_uri: "https://other.example.com/cb", owner: other_user)
      wrong_token = Doorkeeper::AccessToken.create!(application_id: other_app.id, resource_owner_id: user.id, scopes: "default")
      me(wrong_token.token)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user has been discarded after token issuance" do
    it "returns 401" do
      token
      user.discard
      me(token.token)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
