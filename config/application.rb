# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# The Grape API tree lives in app/api/ and is namespaced under API
# (e.g. app/api/v1/base.rb => API::V1::Base). Defined here so the autoloader
# can associate the app/api directory with this namespace below.
module API; end

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Map the app/api directory onto the API namespace so its contents resolve
    # as API::V1::... instead of requiring a redundant app/api/api/ folder.
    Rails.autoloaders.main.push_dir("#{root}/app/api", namespace: API)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Ticket 05: trust docker bridge networks so request.remote_ip reflects
    # the real client from X-Forwarded-For set by the nginx proxy.
    config.action_dispatch.trusted_proxies = [
      IPAddr.new("127.0.0.1"),
      IPAddr.new("::1"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
    ]
  end
end
