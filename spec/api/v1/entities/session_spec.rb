# frozen_string_literal: true

RSpec.describe API::V1::Entities::Session do
  let(:user) { User.create!(email: "entity@example.com", password: "correct horse battery staple") }
  let(:application) do
    OauthApplication.create!(name: "spa", redirect_uri: "https://example.com/cb", owner: user)
  end
  let(:token) do
    Doorkeeper::AccessToken.create!(
      application_id:    application.id,
      resource_owner_id: user.id,
      expires_in:        Doorkeeper.config.access_token_expires_in,
      use_refresh_token: false,
      scopes:            "default"
    )
  end
  let(:payload) { described_class.represent(token).as_json }

  it "exposes the token string as access_token" do
    expect(payload[:access_token]).to eq(token.token)
  end

  it "exposes Bearer as token_type" do
    expect(payload[:token_type]).to eq("Bearer")
  end

  it "exposes expires_in" do
    expect(payload[:expires_in]).to eq(token.expires_in)
  end

  it "exposes created_at as a unix timestamp integer" do
    expect(payload[:created_at]).to eq(token.created_at.to_i)
  end

  it "exposes the resource_owner_id as user_id" do
    expect(payload[:user_id]).to eq(user.id)
  end

  it "exposes an empty roles array when the user has no roles" do
    expect(payload[:roles]).to eq([])
  end

  it "exposes the user's role names when roles are present" do
    user.add_role(:super_admin)
    expect(payload[:roles]).to eq([ "super_admin" ])
  end
end
