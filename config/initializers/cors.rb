# frozen_string_literal: true

origins_csv = Figaro.env.CORS_ORIGINS.to_s
allowed_origins = origins_csv.split(",").map(&:strip).reject(&:empty?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: %i(get post put patch delete options head),
      expose:  %w(Authorization),
      credentials: false
  end
end
