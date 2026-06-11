# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Create < Grape::API
    helpers API::V1::Endpoints::Trucks::Common

    helpers do
      def create_truck
        attrs = truck_params
        ::Trucks::Create.call(
          truck_attrs: attrs.except(:tank),
          tank_attrs:  attrs[:tank],
          created_by:  current_user
        )
      end
    end

    resource :trucks do
      desc "Create a truck together with its tank."
      params do
        requires :plate_number, type: String, documentation: {desc: "The plate number of the truck."}
        requires :vin,          type: String, documentation: {desc: "The VIN of the truck."}
        requires :make,         type: String, documentation: {desc: "The make of the truck."}
        requires :model,        type: String, documentation: {desc: "The model of the truck."}
        requires :year,         type: Integer, documentation: {desc: "The year of the truck."}
        optional :status,       type: String, values: ::Truck.statuses.keys, documentation: {desc: "The status of the truck."}
        requires :tank, type: Hash, documentation: {desc: "The tank attached to the truck."} do
          requires :plate_number,    type: String, documentation: {desc: "The plate number of the tank."}
          requires :capacity, type: Integer, documentation: {desc: "The capacity of the tank in liters."}
          requires :vin,             type: String, documentation: {desc: "The VIN of the tank."}
          requires :make,            type: String, documentation: {desc: "The make of the tank."}
          requires :model,           type: String, documentation: {desc: "The model of the tank."}
          requires :year,            type: Integer, documentation: {desc: "The year of the tank."}
          optional :status,          type: String, values: ::Tank.statuses.keys, documentation: {desc: "The status of the tank."}
        end
      end
      post "/create" do
        authorize!(::Truck, :create)

        present create_truck, with: ::API::V1::Entities::Truck
      end
    end
  end
end
