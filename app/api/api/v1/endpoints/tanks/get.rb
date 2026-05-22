# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Get < Grape::API
    before { authenticate! }

    resource :tanks do
      route_param :id, type: Integer do
        desc "Get a tank."
        get do
          tank = find_kept!(::Tank)
          authorize!(tank, :show)
          present tank, with: ::API::V1::Entities::Tank
        end
      end
    end
  end
end
