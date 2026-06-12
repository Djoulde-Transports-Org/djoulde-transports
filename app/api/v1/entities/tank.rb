# frozen_string_literal: true

module API::V1::Entities
  class Tank < Base
    expose :id, documentation: {type: "Integer", desc: "The ID of the tank."}
    expose :truck_id, documentation: {type: "Integer", desc: "The ID of the truck (head) the tank is attached to."}
    expose :plate_number, documentation: {type: "String", desc: "The plate number of the tank."}
    expose :vin, documentation: {type: "String", desc: "The VIN of the tank."}
    expose :make, documentation: {type: "String", desc: "The make of the tank."}
    expose :model, documentation: {type: "String", desc: "The model of the tank."}
    expose :year, documentation: {type: "Integer", desc: "The year of the tank."}
    expose :capacity, documentation: {type: "Integer", desc: "The capacity of the tank in liters."}
    expose :status, documentation: {type: "String", desc: "The status of the tank."}
    expose :created_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The creation time."}
    expose :updated_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The last update time."}
    expose :discarded_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The discard time."}
  end
end
