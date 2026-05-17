if Rails.env.production?
  Figaro.require_keys(
    "DATABASE_HOST",
    "DATABASE_NAME",
    "REDIS_URL",
    "SECRET_KEY_BASE"
  )
end
