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
    expose :driver,          using: ::API::V1::Entities::Employee,        documentation: {type: "Object", desc: "The driver assigned to the trip."} do |trip, _opts|
      trip.driver || trip.truck.driver
    end
    expose :route,           using: ::API::V1::Entities::Route,           documentation: {type: "Object", desc: "The route of the trip."}
    expose :delivery_note,   using: ::API::V1::Entities::DeliveryNote,    documentation: {type: "Object", desc: "The delivery note for the trip."}
    expose :billing_statement, using: ::API::V1::Entities::BillingStatement,
           documentation: {type: "Object", desc: "The billing statement for the trip."} do |trip, _opts|
      trip.billing_line_items.first&.billing_statement
    end

    expose :pretax_amount,
           documentation: {type: "Integer",
                           desc: "Pre-tax amount (montant HT). Uses the locked-in billed " \
                                 "amount once invoiced, otherwise an estimate from " \
                                 "quantities x route rate."} do |_trip, _opts|
      pretax_amount
    end

    private

    def pretax_amount
      object.billing_line_items.first&.amount || estimated_pretax_amount
    end

    def estimated_pretax_amount
      note  = object.delivery_note
      route = object.route
      return nil unless note && route

      ((note.gasoline_quantity + note.diesel_quantity) * route.rate).round.to_i
    end
  end
end
