# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Create < Grape::API
    helpers API::V1::Endpoints::Trucks::Common

    helpers do
      def create_truck
        truck = ::Truck.new(truck_params)
        truck.created_by = current_user
        truck.save!
        truck
      end
    end

    resource :trucks do
      desc "Create a truck."
      params do
        requires :plate_number, type: String, documentation: {desc: "The plate number of the truck."}
        requires :vin,          type: String, documentation: {desc: "The VIN of the truck."}
        requires :make,         type: String, documentation: {desc: "The make of the truck."}
        requires :model,        type: String, documentation: {desc: "The model of the truck."}
        requires :year,         type: Integer, documentation: {desc: "The year of the truck."}
        optional :status,       type: String, values: ::Truck.statuses.keys, documentation: {desc: "The status of the truck."}
      end
      post do
        authorize!(::Truck, :create)

        present create_truck, with: ::API::V1::Entities::Truck
      end
    end
  end
end
