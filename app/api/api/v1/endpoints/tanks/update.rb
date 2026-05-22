# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Update < Grape::API
    before { authenticate! }

    resource :tanks do
      route_param :id, type: Integer do
        desc "Update a tank. Reassignment to a new truck is allowed (rare swap path)."
        params do
          optional :truck_id,        type: Integer
          optional :plate_number,    type: String
          optional :vin,             type: String
          optional :make,            type: String
          optional :model,           type: String
          optional :year,            type: Integer
          optional :capacity_liters, type: Integer
          optional :status,          type: String, values: ::Tank.statuses.keys
        end
        patch "/update" do
          tank = find_kept!(::Tank)
          authorize!(tank, :update)
          tank.update!(declared(params, include_missing: false).except(:id))
          present tank, with: ::API::V1::Entities::Tank
        end
      end
    end
  end
end
