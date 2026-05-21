# frozen_string_literal: true

require "rack/attack"

Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
  url: Figaro.env.REDIS_URL || ENV.fetch("REDIS_URL"),
  namespace: "rack-attack"
)

Rack::Attack.safelist("allow /up") do |req|
  req.path == "/up"
end

# TODO(ticket-09): confirm /oauth/token is the final login path once Doorkeeper lands.
Rack::Attack.throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
  req.ip if req.post? && req.path == "/oauth/token"
end

Rack::Attack.throttle("api/ip", limit: 300, period: 60.seconds) do |req|
  req.ip if req.path.start_with?("/api/")
end

Rack::Attack.throttled_responder = lambda do |request|
  match_data = request.env["rack.attack.match_data"] || {}
  retry_after = match_data[:period].to_i
  body = {error: "rate_limited", retry_after: retry_after}.to_json

  [
    429,
    {"Content-Type" => "application/json", "Retry-After" => retry_after.to_s},
    [ body ],
  ]
end
