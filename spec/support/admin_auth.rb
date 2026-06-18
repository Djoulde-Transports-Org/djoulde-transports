# frozen_string_literal: true

# Devise session helpers for the Active Admin (ticket 12) request specs, which
# drive the cookie-authenticated /admin UI rather than the token API.
require "devise"

module AdminAuth
  PASSWORD = "correct horse battery staple"

  def create_admin(email: nil)
    admin = User.create!(email: email || "admin-#{SecureRandom.hex(2)}@example.com", password: PASSWORD)
    admin.add_role(:super_admin)
    admin
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include AdminAuth, type: :request
end
