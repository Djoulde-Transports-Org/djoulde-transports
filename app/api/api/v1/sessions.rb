module API::V1
  class Sessions < Grape::API
    resource :sessions do
      desc "Log in with email + password; receive a Doorkeeper access token."
      params do
        requires :email,    type: String
        requires :password, type: String
      end
      post do
        user = User.find_for_authentication(email: params[:email])

        unless user&.valid_password?(params[:password])
          error!({ error: "invalid_credentials" }, 401)
        end

        unless user.active_for_authentication?
          error!({ error: user.inactive_message.to_s }, 403)
        end

        application = user.oauth_application
        if application.nil?
          error!({ error: "api_access_denied_no_application" }, 403)
        end

        token = Doorkeeper::AccessToken.create!(
          application_id:    application.id,
          resource_owner_id: user.id,
          expires_in:        Doorkeeper.config.access_token_expires_in,
          use_refresh_token: false,
          scopes:            "default"
        )

        {
          access_token: token.token,
          token_type:   "Bearer",
          expires_in:   token.expires_in,
          created_at:   token.created_at.to_i,
          user_id:      user.id
        }
      end
    end
  end
end
