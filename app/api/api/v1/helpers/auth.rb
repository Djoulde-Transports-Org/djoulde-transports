# frozen_string_literal: true

module API::V1::Helpers
  # Bearer-token authentication for Grape endpoints.
  #
  # `authenticate!` enforces three checks before returning:
  #   1. The Doorkeeper access token is valid.
  #   2. The token's resource owner exists and is kept (not discarded).
  #   3. `token.application.owner_id` matches the resource owner.
  #
  # After those pass it stamps `Current.user` and bumps the application's
  # `calls_count` + `last_used_at` (ticket 11 instrumentation). The bump uses
  # `update_all` so it skips Active Record callbacks and `updated_at`, keeping
  # the per-request overhead to a single UPDATE.
  module Auth
    extend Grape::API::Helpers

    def doorkeeper_token
      @doorkeeper_token ||= Doorkeeper.authenticate(
        ActionDispatch::Request.new(env), Doorkeeper.config.access_token_methods
      )
    end

    def current_user
      return nil unless doorkeeper_token

      @current_user = User.kept.find_by(id: doorkeeper_token.resource_owner_id) unless defined?(@current_user)
      @current_user
    end

    def authenticate!
      unauthorized! unless doorkeeper_token&.acceptable?(nil)
      unauthorized! if current_user.nil?
      app = doorkeeper_token.application
      unauthorized! if app.nil?
      unauthorized! if app.owner_id != current_user.id || app.owner_type != "User"
      Current.user = current_user
      stamp_application_usage(app)
    end

    private

    def stamp_application_usage(app)
      # Single UPDATE per authenticated request. Intentionally skips
      # callbacks/`updated_at` so the hook stays cheap.
      OauthApplication.where(id: app.id)
        .update_all([ "calls_count = calls_count + 1, last_used_at = ?", Time.current ]) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
