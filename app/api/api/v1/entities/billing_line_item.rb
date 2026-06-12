# frozen_string_literal: true

module API::V1::Entities
  class BillingLineItem < Base
    expose :id,                       documentation: {type: "Integer", desc: "The ID of the line item."}
    expose :billing_statement_id,     documentation: {type: "Integer", desc: "The ID of the statement this line item belongs to."}
    expose :trip_id,                  documentation: {type: "Integer", desc: "The ID of the trip this line item snapshots."}
    expose :delivery_note_number,     documentation: {type: "String",  desc: "The delivery note number."}
    expose :started_on,               documentation: {type: "Date",    desc: "The date the trip started."}
    expose :origin,                   documentation: {type: "String",  desc: "The trip origin."}
    expose :destination,              documentation: {type: "String",  desc: "The trip destination."}
    expose :gasoline_quantity,        documentation: {type: "Integer", desc: "Litres of gasoline delivered."}
    expose :diesel_quantity,          documentation: {type: "Integer", desc: "Litres of diesel delivered."}
    expose :rate,                     documentation: {type: "Float",   desc: "The rate applied to the trip."}
    expose :amount,                   documentation: {type: "Float",   desc: "The line item amount before tax."}
    expose :tva,                      documentation: {type: "Float",   desc: "The tax (TVA) on the line item."}
    expose :created_at,   format_with: :iso_8601, documentation: {type: "DateTime", desc: "The creation time."}
    expose :updated_at,   format_with: :iso_8601, documentation: {type: "DateTime", desc: "The last update time."}
    expose :discarded_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The discard time."}
  end
end
