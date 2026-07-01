# frozen_string_literal: true

module API::V1::Endpoints::Users::Session
  class Delete < Grape::API
    before { authenticate! }

    resource :sessions do
      desc "Log out; revoke the current bearer token."
      delete do
        doorkeeper_token.revoke
        {success: true}
      end
    end
  end
end
