# frozen_string_literal: true

module API::V1::Entities
  class DeliveryNote < Base
    expose :id, documentation: {type: "Integer", desc: "The ID of the delivery note."}
    expose :trip_id, documentation: {type: "Integer", desc: "The ID of the trip the delivery note belongs to."}
    expose :number, documentation: {type: "String", desc: "The delivery note number."}
    expose :delivered_on, format_with: :iso_8601_date, documentation: {type: "Date", desc: "The date the cargo was delivered."}
    expose :gasoline_quantity, documentation: {type: "Integer", desc: "The gasoline quantity in liters."}
    expose :diesel_quantity, documentation: {type: "Integer", desc: "The diesel quantity in liters."}
    expose :missing_quantity, documentation: {type: "Integer", desc: "The quantity missing on delivery, in liters."}
    expose :product, documentation: {type: "String", desc: "The product carried (gasoline, diesel, or both)."} do |dn, _opts|
      dn.product&.to_s
    end
  end
end
