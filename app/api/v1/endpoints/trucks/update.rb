# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Update < Grape::API
    helpers API::V1::Endpoints::Trucks::Common

    helpers do
      def update_truck!
        attrs = truck_params
        ::Trucks::Update.call(
          truck,
          truck_attrs: attrs.except(:tank),
          tank_attrs:  attrs[:tank]
        )
      end
    end

    resource :trucks do
      route_param :id, type: Integer do
        desc "Update a truck and, optionally, its tank."
        params do
          optional :plate_number, type: String, documentation: {desc: "The plate number of the truck."}
          optional :vin,          type: String, documentation: {desc: "The VIN of the truck."}
          optional :make,         type: String, documentation: {desc: "The make of the truck."}
          optional :model,        type: String, documentation: {desc: "The model of the truck."}
          optional :year,         type: Integer, documentation: {desc: "The year of the truck."}
          optional :status,     type: String,  values: ::Truck.statuses.keys, documentation: {desc: "The status of the truck."}
          optional :driver_id,  type: Integer, documentation: {desc: "The ID of the driver (Employee) to assign to the truck."}
          optional :tank, type: Hash, documentation: {desc: "Attributes of the tank attached to the truck."} do
            optional :plate_number,    type: String, documentation: {desc: "The plate number of the tank."}
            optional :vin,             type: String, documentation: {desc: "The VIN of the tank."}
            optional :make,            type: String, documentation: {desc: "The make of the tank."}
            optional :model,           type: String, documentation: {desc: "The model of the tank."}
            optional :year,            type: Integer, documentation: {desc: "The year of the tank."}
            optional :capacity, type: Integer, documentation: {desc: "The capacity of the tank in liters."}
            optional :status,          type: String, values: ::Tank.statuses.keys, documentation: {desc: "The status of the tank."}
          end
        end
        patch "/update" do
          authorize!(truck, :update)
          update_truck!

          present truck, with: ::API::V1::Entities::Truck
        end
      end
    end
  end
end
