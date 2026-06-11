# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Update < Grape::API
    helpers API::V1::Endpoints::Tanks::Common

    helpers do
      def update_tank!
        tank.update!(tank_params)
      end
    end

    resource :tanks do
      route_param :id, type: Integer do
        desc "Update a tank. Reassignment to a new truck is allowed (rare swap path)."
        params do
          optional :truck_id,        type: Integer, documentation: {desc: "The ID of the truck (head) the tank is attached to."}
          optional :plate_number,    type: String, documentation: {desc: "The plate number of the tank."}
          optional :vin,             type: String, documentation: {desc: "The VIN of the tank."}
          optional :make,            type: String, documentation: {desc: "The make of the tank."}
          optional :model,           type: String, documentation: {desc: "The model of the tank."}
          optional :year,            type: Integer, documentation: {desc: "The year of the tank."}
          optional :capacity_liters, type: Integer, documentation: {desc: "The capacity of the tank in liters."}
          optional :status,          type: String, values: ::Tank.statuses.keys, documentation: {desc: "The status of the tank."}
        end
        patch "/update" do
          authorize!(tank, :update)
          update_tank!

          present tank, with: ::API::V1::Entities::Tank
        end
      end
    end
  end
end
