# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v1/sessions", type: :request do
  let(:password) { "correct horse battery staple" }
  let(:user)     { User.create!(email: "u@example.com", password: password) }
  let(:oauth_app) do
    OauthApplication.create!(name: "spa", redirect_uri: "https://example.com/cb", owner: user)
  end

  def login(email:, password:)
    post "/api/v1/sessions",
      params: {email: email, password: password}.to_json,
      headers: {"Content-Type" => "application/json"}
  end

  context "with valid credentials and an OauthApplication" do
    before do
      oauth_app
      login(email: user.email, password: password)
    end

    it "returns 201 Created" do
      expect(response).to have_http_status(:created)
    end

    it "returns a Bearer token_type" do
      expect(response.parsed_body["token_type"]).to eq("Bearer")
    end

    it "returns an access_token string" do
      expect(response.parsed_body["access_token"]).to be_a(String)
    end

    it "returns the user_id" do
      expect(response.parsed_body["user_id"]).to eq(user.id)
    end
  end

  context "without an OauthApplication" do
    before { login(email: user.email, password: password) }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "returns the api_access_denied_no_application error code" do
      expect(response.parsed_body["error"]).to eq("api_access_denied_no_application")
    end
  end

  context "with invalid credentials" do
    before { login(email: user.email, password: "wrong") }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns invalid_credentials" do
      expect(response.parsed_body["error"]).to eq("invalid_credentials")
    end
  end

  context "when the user is discarded" do
    before do
      oauth_app
      user.discard
      login(email: user.email, password: password)
    end

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "returns the discarded error code" do
      expect(response.parsed_body["error"]).to eq("discarded")
    end
  end
end
