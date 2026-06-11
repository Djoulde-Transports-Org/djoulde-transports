# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Create < Grape::API
    helpers API::V1::Endpoints::Tanks::Common

    helpers do
      def create_tank
        tank = ::Tank.new(tank_params)
        tank.save!
        tank
      end
    end

    resource :tanks do
      desc "Create a tank attached to a head (truck)."
      params do
        requires :truck_id,        type: Integer, documentation: {desc: "The ID of the truck (head) the tank is attached to."}
        requires :plate_number,    type: String, documentation: {desc: "The plate number of the tank."}
        requires :capacity_liters, type: Integer, documentation: {desc: "The capacity of the tank in liters."}
        optional :vin,             type: String, documentation: {desc: "The VIN of the tank."}
        optional :make,            type: String, documentation: {desc: "The make of the tank."}
        optional :model,           type: String, documentation: {desc: "The model of the tank."}
        optional :year,            type: Integer, documentation: {desc: "The year of the tank."}
        optional :status,          type: String, values: ::Tank.statuses.keys, documentation: {desc: "The status of the tank."}
      end
      post "/create" do
        authorize!(::Tank, :create)

        present create_tank, with: ::API::V1::Entities::Tank
      end
    end
  end
end
