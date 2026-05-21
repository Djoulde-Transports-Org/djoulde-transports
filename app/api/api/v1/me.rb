# frozen_string_literal: true

module API::V1
  class Me < Grape::API
    before { authenticate! }

    resource :me do
      desc "Return the authenticated user with roles."
      get do
        {
          id:    current_user.id,
          email: current_user.email,
          roles: current_user.roles.pluck(:name),
        }
      end
    end
  end
end
