# frozen_string_literal: true

module API::V1::Entities
  class Trip < Base
    expose :id, documentation: {type: "Integer", desc: "The ID of the trip."}
    expose :truck_id, documentation: {type: "Integer", desc: "The ID of the truck assigned to the trip."}
    expose :tank_id, documentation: {type: "Integer", desc: "The ID of the tank assigned to the trip."}
    expose :route_id, documentation: {type: "Integer", desc: "The ID of the route of the trip."}
    expose :driver_id, documentation: {type: "Integer", desc: "The ID of the driver assigned to the trip."}
    expose :status, documentation: {type: "String", desc: "The status of the trip."}
    expose :cargo_description, documentation: {type: "String", desc: "A description of the cargo."}
    expose :distance_km, documentation: {type: "Float", desc: "The distance of the trip in kilometers."} do |trip, _opts|
      trip.distance_km&.to_f
    end
    expose :scheduled_start_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The scheduled start time."}
    expose :scheduled_end_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The scheduled end time."}
    expose :actual_start_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The actual start time."}
    expose :actual_end_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The actual end time."}
    expose :delivery_note, using: ::API::V1::Entities::DeliveryNote, documentation: {type: "Object", desc: "The delivery note (loading document) for the trip."}
    expose :created_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The creation time."}
    expose :updated_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The last update time."}
    expose :discarded_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The discard time."}
  end
end
