# frozen_string_literal: true

module API::V1::Endpoints::Trips
  class Create < Grape::API
    helpers API::V1::Endpoints::Trips::Common

    helpers do
      def create_trip
        trip = ::Trip.new(trip_params)
        trip.save!
        trip
      end
    end

    resource :trips do
      desc "Create a trip."
      params do
        requires :truck_id,           type: Integer, documentation: {desc: "The truck assigned to the trip."}
        requires :route_id,           type: Integer, documentation: {desc: "The route of the trip."}
        optional :tank_id,            type: Integer, documentation: {desc: "Defaults to the truck's currently paired tank."}
        optional :driver_id,          type: Integer, documentation: {desc: "The driver assigned to the trip."}
        optional :status,             type: String, values: ::Trip.statuses.keys, documentation: {desc: "The status of the trip."}
        optional :scheduled_start_at, type: DateTime, documentation: {desc: "The scheduled start time."}
        optional :scheduled_end_at,   type: DateTime, documentation: {desc: "The scheduled end time."}
        optional :actual_start_at,    type: DateTime, documentation: {desc: "The actual start time."}
        optional :actual_end_at,      type: DateTime, documentation: {desc: "The actual end time."}
        optional :cargo_description,  type: String, documentation: {desc: "A description of the cargo."}
        optional :distance_km,        type: BigDecimal, documentation: {desc: "The distance of the trip in kilometers."}
      end
      post "/create" do
        authorize!(::Trip, :create)

        present create_trip, with: ::API::V1::Entities::Trip
      end
    end
  end
end
