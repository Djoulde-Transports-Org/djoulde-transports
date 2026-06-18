# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i( windows jruby )

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 2.0"

# ENV-driven config loaded from config/application.yml [https://github.com/laserlemon/figaro]
gem "figaro", "~> 1.2"

# Soft-delete via discarded_at columns, no global default_scope [https://github.com/jhawthorn/discard]
gem "discard", "~> 2.0"

# Audit trail of model changes; ticket 10 wires `audited` into business models [https://github.com/collectiveidea/audited]
gem "audited", "~> 5.7"

# Redis client and the high-performance hiredis driver
gem "redis", "~> 5.3"
gem "hiredis-client", "~> 0.30"

# Throttling + CORS middleware (config under config/initializers/)
gem "rack-attack", "~> 6.7"
gem "rack-cors", "~> 3.0"

# OAuth2 provider; custom application class lands in app/models/oauth_application.rb (ticket 08)
gem "doorkeeper", "~> 5.9"

# User authentication (ticket 09): database_authenticatable, confirmable, lockable, trackable, recoverable
gem "devise", "~> 5.0", ">= 5.0.4"

# Role-based access control on User (ticket 09)
gem "rolify", "~> 6.0"

# Grape mounts the JSON API at /api/v1 (sessions + me here; rest of the API in ticket 11)
gem "grape", "~> 3.2"
gem "grape-entity", "~> 1.1"

# Policy-based authorization for Grape endpoints (ticket 11)
gem "pundit", "~> 2.4"

# Pagination for Grape list endpoints (sets Total, Per-Page, Link headers)
gem "kaminari", "~> 1.2"
gem "api-pagination", "~> 7.1"

# Internal admin CRUD at /admin (ticket 12). The 4.x line is the propshaft +
# importmap native release; its Tailwind CSS is built nodeless via the
# tailwindcss-rails standalone CLI (no node/yarn). Session auth reuses the
# Devise User model, gated to the super_admin role.
gem "activeadmin", "4.0.0.beta22"
gem "tailwindcss-rails", "~> 4.4"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i( mri windows ), require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # RSpec cops layered on top of omakase
  gem "rubocop-rspec", require: false

  # Additional rubocop plugins referenced in .rubocop.yml
  gem "rubocop-factory_bot", require: false
  gem "rubocop-migration", require: false

  # RSpec test framework for Rails
  gem "rspec-rails", "~> 8.0"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Open Devise emails in the browser instead of sending them (ticket 09)
  gem "letter_opener", "~> 1.10"

  # Annotate models with schema info as comments
  # Maintained fork of `annotate` with Rails 8 support [https://github.com/drwl/annotaterb]
  gem "annotaterb", "~> 4.16"
end
