# frozen_string_literal: true

module API::V1::Endpoints::Users
  class Sessions < Grape::API
    helpers do
      def user
        @user ||= User.find_for_authentication(email: params[:email])
      end

      def user_valid!
        forbidden!(code: user.inactive_message.to_s, message: "Account is not active.") unless user.active_for_authentication?
      end

      def password_valid!
        unauthorized!(
          code: "invalid_credentials",
          message: "Invalid email or password."
        ) unless user&.valid_password?(params[:password])
      end


      def application
        @application ||= user.oauth_application
      end

      def application_exists!
        forbidden!(
          code: "api_access_denied_no_application",
          message: "This account has no API application."
        ) if application.blank?
      end

      def token
        Doorkeeper::AccessToken.create!(
          application_id:    application.id,
          resource_owner_id: user.id,
          expires_in:        Doorkeeper.config.access_token_expires_in,
          use_refresh_token: false,
          scopes:            "default"
        )
      end
    end

    resource :sessions do
      desc "Log in with email + password; receive a Doorkeeper access token."
      params do
        requires :email,    type: String, documentation: {type: "string", desc: "The email address"}
        requires :password, type: String, documentation: {type: "string", desc: "The password"}
      end
      post do
        password_valid!
        user_valid!
        application_exists!

        present token, with: API::V1::Entities::Session
      end
    end
  end
end
