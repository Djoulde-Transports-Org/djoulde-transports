# frozen_string_literal: true

module API::V1::Entities
  class Trip < Base
    expose :id,               documentation: {type: "Integer", desc: "The ID of the trip."}
    expose :status,           documentation: {type: "String",  desc: "The status of the trip."}
    expose :cargo_description, documentation: {type: "String", desc: "A description of the cargo."}
    expose :distance_km,      documentation: {type: "Float",   desc: "The distance of the trip in kilometers."} do |trip, _opts|
      trip.distance_km&.to_f
    end
    expose :scheduled_start_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The scheduled start time."}
    expose :scheduled_end_at,   format_with: :iso_8601, documentation: {type: "DateTime", desc: "The scheduled end time."}
    expose :actual_start_at,    format_with: :iso_8601, documentation: {type: "DateTime", desc: "The actual start time."}
    expose :actual_end_at,      format_with: :iso_8601, documentation: {type: "DateTime", desc: "The actual end time."}

    expose :truck,           using: ::API::V1::Entities::Truck,           documentation: {type: "Object", desc: "The truck assigned to the trip."}
    expose :route,           using: ::API::V1::Entities::Route,           documentation: {type: "Object", desc: "The route of the trip."}
    expose :delivery_note,   using: ::API::V1::Entities::DeliveryNote,    documentation: {type: "Object", desc: "The delivery note for the trip."}
    expose :billing_statement, using: ::API::V1::Entities::BillingStatement, documentation: {type: "Object", desc: "The billing statement for the trip."}
  end
end
