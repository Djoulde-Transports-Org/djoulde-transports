# frozen_string_literal: true

module API::V1::Endpoints::Users
  class Me < Grape::API
    before { authenticate! }

    resource :me do
      desc "Return the authenticated user with roles."
      get do
        present current_user, with: API::V1::Entities::User
      end
    end
  end
end
