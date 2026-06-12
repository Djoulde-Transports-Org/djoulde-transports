# frozen_string_literal: true

module API::V1::Endpoints::Trips
  class Update < Grape::API
    helpers API::V1::Endpoints::Trips::Common

    helpers do
      def update_trip!
        ::Trips::Update.call(trip, trip_params, missing_quantity_param)
      end
    end

    resource :trips do
      route_param :id, type: Integer do
        desc "Update a trip."
        params do
          optional :truck_id,           type: Integer, documentation: {desc: "The truck assigned to the trip."}
          optional :tank_id,            type: Integer, documentation: {desc: "The tank assigned to the trip."}
          optional :route_id,           type: Integer, documentation: {desc: "The route of the trip."}
          optional :driver_id,          type: Integer, documentation: {desc: "The driver assigned to the trip."}
          optional :status,             type: String, values: ::Trip.statuses.keys, documentation: {desc: "The status of the trip."}
          optional :scheduled_start_at, type: DateTime, documentation: {desc: "The scheduled start time."}
          optional :scheduled_end_at,   type: DateTime, documentation: {desc: "The scheduled end time."}
          optional :actual_start_at,    type: DateTime, documentation: {desc: "The actual start time."}
          optional :actual_end_at,      type: DateTime, documentation: {desc: "The actual end time."}
          optional :cargo_description,  type: String, documentation: {desc: "A description of the cargo."}
          optional :distance_km,        type: BigDecimal, documentation: {desc: "The distance of the trip in kilometers."}
          optional :missing_quantity, type: Integer, documentation: {desc: "The quantity missing on delivery, recorded when completing the trip."}
        end
        patch "/update" do
          authorize!(trip, :update)
          update_trip!

          present trip, with: ::API::V1::Entities::Trip
        end
      end
    end
  end
end
