require "rails_helper"

RSpec.describe "Rack::Attack configuration" do
  it "uses a Redis-backed cache store" do
    expect(Rack::Attack.cache.store.class.name).to include("Redis")
  end

  it "safelists the /up health route" do
    expect(Rack::Attack.safelists).to have_key("allow /up")
  end

  it "registers the logins/ip throttle with a non-zero limit" do
    expect(Rack::Attack.throttles["logins/ip"]&.limit).to be > 0
  end

  it "registers the api/ip throttle with a non-zero limit" do
    expect(Rack::Attack.throttles["api/ip"]&.limit).to be > 0
  end
end
