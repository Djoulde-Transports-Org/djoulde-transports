# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Get < Grape::API
    before { authenticate! }

    resource :trucks do
      route_param :id, type: Integer do
        desc "Get a truck."
        get do
          truck = find_kept!(::Truck)
          authorize!(truck, :show)
          present truck, with: ::API::V1::Entities::Truck
        end
      end
    end
  end
end
