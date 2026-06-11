# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Get < Grape::API
    helpers API::V1::Endpoints::Tanks::Common

    resource :tanks do
      route_param :id, type: Integer do
        desc "Get a tank."
        get do
          authorize!(tank, :show)
          present tank, with: ::API::V1::Entities::Tank
        end
      end
    end
  end
end
