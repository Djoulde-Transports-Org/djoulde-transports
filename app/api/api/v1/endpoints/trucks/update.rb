# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Update < Grape::API
    before { authenticate! }

    resource :trucks do
      route_param :id, type: Integer do
        desc "Update a truck."
        params do
          optional :plate_number, type: String
          optional :vin,          type: String
          optional :make,         type: String
          optional :model,        type: String
          optional :year,         type: Integer
          optional :status,       type: String, values: ::Truck.statuses.keys
        end
        patch do
          truck = find_kept!(::Truck)
          authorize!(truck, :update)
          truck.update!(declared(params, include_missing: false).except(:id))
          present truck, with: ::API::V1::Entities::Truck
        end
      end
    end
  end
end
