# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Create < Grape::API
    helpers API::V1::Endpoints::Trucks::Common

    helpers do
      def create_truck
        attrs = truck_params
        ::Trucks::Create.call(
          truck_attrs:         attrs.except(:tank, :last_oil_change_on, :documents),
          tank_attrs:          attrs[:tank],
          last_oil_change_on:  attrs[:last_oil_change_on],
          document_expiries:   attrs[:documents] || {},
          created_by:          current_user
        )
      end
    end

    resource :trucks do
      desc "Create a truck together with its tank."
      params do
        requires :plate_number, type: String, documentation: {desc: "The plate number of the truck."}
        optional :vin,          type: String, documentation: {desc: "The VIN of the truck."}
        optional :make,         type: String, documentation: {desc: "The make of the truck."}
        requires :model,        type: String, documentation: {desc: "The model of the truck."}
        requires :year,         type: Integer, documentation: {desc: "The year of the truck."}
        optional :status,     type: String,  values: ::Truck.statuses.keys, documentation: {desc: "The status of the truck."}
        optional :driver_id,  type: Integer, documentation: {desc: "The ID of the driver (Employee) to assign to the truck."}
        optional :last_oil_change_on, type: Date, documentation: {desc: "Date of the truck's last oil change."}
        requires :tank, type: Hash, documentation: {desc: "The tank attached to the truck."} do
          requires :plate_number,    type: String, documentation: {desc: "The plate number of the tank."}
          requires :capacity, type: Integer, documentation: {desc: "The capacity of the tank in liters."}
          optional :vin,             type: String, documentation: {desc: "The VIN of the tank."}
          optional :make,            type: String, documentation: {desc: "The make of the tank."}
          optional :model,           type: String, documentation: {desc: "The model of the tank."}
          optional :year,            type: Integer, documentation: {desc: "The year of the tank."}
          optional :status,          type: String, values: ::Tank.statuses.keys, documentation: {desc: "The status of the tank."}
        end
        optional :documents, type: Hash, documentation: {desc: "Expiry dates for the truck's documents."} do
          optional :truck_insurance_expires_on,     type: Date, documentation: {desc: "Truck insurance expiry date."}
          optional :cargo_insurance_expires_on,     type: Date, documentation: {desc: "Cargo insurance expiry date."}
          optional :technical_inspection_expires_on, type: Date, documentation: {desc: "Technical inspection expiry date."}
          optional :operating_permit_expires_on,    type: Date, documentation: {desc: "Operating permit (transport card) expiry date."}
          optional :truck_registration_expires_on,  type: Date, documentation: {desc: "Truck registration expiry date."}
        end
      end
      post "/create" do
        authorize!(::Truck, :create)

        present create_truck, with: ::API::V1::Entities::Truck
      end
    end
  end
end
