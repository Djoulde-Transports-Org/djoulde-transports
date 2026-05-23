# frozen_string_literal: true

# Lightweight helpers for ticket-11 request specs. Builds a user + their
# OauthApplication + an access token, and returns the Authorization header.
module ApiAuth
  PASSWORD = "correct horse battery staple"

  def create_user(email:, roles: [])
    user = User.create!(email: email, password: PASSWORD)
    roles.each { |role| user.add_role(role) }
    user
  end

  def issue_token_for(user, app: nil)
    app ||= OauthApplication.create!(
      name: "spa-#{user.id}", redirect_uri: "https://example.com/cb", owner: user
    )
    token = Doorkeeper::AccessToken.create!(
      application_id: app.id,
      resource_owner_id: user.id,
      scopes: "default"
    )
    [ token, app ]
  end

  def bearer_headers(token, extra = {})
    {"Authorization" => "Bearer #{token.token}"}.merge(extra)
  end

  def auth_setup(role: :super_admin, email: nil)
    suffix = email || "#{role}-#{SecureRandom.hex(2)}@example.com"
    user        = create_user(email: suffix, roles: Array(role))
    token, app  = issue_token_for(user)
    [ user, token, app ]
  end
end

RSpec.configure do |config|
  config.include ApiAuth, type: :request
end
