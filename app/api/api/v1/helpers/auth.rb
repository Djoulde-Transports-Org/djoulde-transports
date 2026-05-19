module API::V1::Helpers
  module Auth
    extend Grape::API::Helpers

    def doorkeeper_token
      @doorkeeper_token ||= Doorkeeper.authenticate(
        ActionDispatch::Request.new(env), Doorkeeper.config.access_token_methods
      )
    end

    def current_user
      return nil unless doorkeeper_token

      @current_user ||= User.kept.find_by(id: doorkeeper_token.resource_owner_id)
    end

    def authenticate!
      unauthorized! unless doorkeeper_token&.acceptable?(nil)
      unauthorized! if current_user.nil?
      app = doorkeeper_token.application
      unauthorized! if app.nil?
      unauthorized! if app.owner_id != current_user.id || app.owner_type != "User"
      Current.user = current_user
    end

    def unauthorized!
      error!({ error: "unauthorized" }, 401)
    end
  end
end
