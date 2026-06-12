# frozen_string_literal: true

module API::V1::Endpoints::Trips
  class Get < Grape::API
    helpers API::V1::Endpoints::Trips::Common

    resource :trips do
      route_param :id, type: Integer do
        desc "Get a trip."
        get do
          authorize!(trip, :show)
          present trip, with: ::API::V1::Entities::Trip
        end
      end
    end
  end
end
