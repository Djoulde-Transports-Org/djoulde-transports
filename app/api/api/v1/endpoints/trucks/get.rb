# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Get < Grape::API
    helpers API::V1::Endpoints::Trucks::Common

    resource :trucks do
      route_param :id, type: Integer do
        desc "Get a truck."
        get do
          authorize!(truck, :show)
          present truck, with: ::API::V1::Entities::Truck
        end
      end
    end
  end
end
