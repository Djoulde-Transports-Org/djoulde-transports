# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Users::Session::Create do
  subject(:do_request) do
    post "/api/v1/sessions", params: {email: email, password: password_param}
  end

  let(:password)       { "correct horse battery staple" }
  let(:user)           { User.create!(email: "u@example.com", password: password) }
  let(:email)          { user.email }
  let(:password_param) { password }
  let(:oauth_app) do
    OauthApplication.create!(name: "spa", redirect_uri: "https://example.com/cb", owner: user)
  end

  context "with valid credentials and an OauthApplication" do
    before do
      oauth_app
      do_request
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

    it "returns an empty roles array when the user has no roles" do
      expect(response.parsed_body["roles"]).to eq([])
    end
  end

  context "when the user has roles" do
    before do
      user.add_role(:super_admin)
      oauth_app
      do_request
    end

    it "returns 201 Created" do
      expect(response).to have_http_status(:created)
    end

    it "returns the user's roles in the response" do
      expect(response.parsed_body["roles"]).to eq([ "super_admin" ])
    end
  end

  context "when session establishment after a successful login" do
    before do
      oauth_app
      do_request
    end

    it "stores token_expires_at in the session as a future unix timestamp" do
      expect(session[:token_expires_at]).to be_a(Integer).and be > Time.current.to_i
    end

    it "establishes a Devise session for the user via Warden" do
      expect(request.env["warden"].user(:user)).to eq(user)
    end
  end

  context "without an OauthApplication" do
    before { do_request }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "returns the api_access_denied_no_application error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("api_access_denied_no_application")
    end
  end

  context "with invalid credentials" do
    let(:password_param) { "wrong" }

    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns invalid_credentials" do
      expect(response.parsed_body.dig("error", "code")).to eq("invalid_credentials")
    end
  end

  context "when the user is discarded" do
    before do
      oauth_app
      user.discard
      do_request
    end

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "returns the discarded error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("discarded")
    end
  end
end
