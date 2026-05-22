# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OauthApplication usage instrumentation", type: :request do
  let(:setup)     { auth_setup }
  let(:user)      { setup[0] }
  let(:token)     { setup[1] }
  let(:oauth_app) { setup[2] }

  it "increments calls_count on each authenticated request" do
    expect {
      get "/api/v1/me", headers: bearer_headers(token)
    }.to change { oauth_app.reload.calls_count }.by(1)
  end

  it "stamps last_used_at on each authenticated request" do
    oauth_app.update_column(:last_used_at, nil) # rubocop:disable Rails/SkipsModelValidations
    get "/api/v1/me", headers: bearer_headers(token)
    expect(oauth_app.reload.last_used_at).to be_present
  end

  it "does not increment on unauthenticated requests" do
    oauth_app
    expect {
      get "/api/v1/me"
    }.not_to(change { oauth_app.reload.calls_count })
  end
end
