# frozen_string_literal: true

module API::V1::Entities
  class Truck < Base
    expose :id, documentation: {type: "Integer", desc: "The ID of the truck."}
    expose :plate_number, documentation: {type: "String", desc: "The plate number of the truck."}
    expose :vin, documentation: {type: "String", desc: "The VIN of the truck."}
    expose :make, documentation: {type: "String", desc: "The make of the truck."}
    expose :model, documentation: {type: "String", desc: "The model of the truck."}
    expose :year, documentation: {type: "Integer", desc: "The year of the truck."}
    expose :status, documentation: {type: "String", desc: "The status of the truck."}
    expose :created_by_id, documentation: {type: "Integer", desc: "The ID of the user who created the truck."}
    expose :created_at, documentation: {type: "DateTime", desc: "The creation time."}
    expose :updated_at, documentation: {type: "DateTime", desc: "The last update time."}
    expose :discarded_at, documentation: {type: "DateTime", desc: "The discard time."}
    expose :tank, using: ::API::V1::Entities::Tank, documentation: {type: "Object", desc: "The tank attached to the truck."}
  end
end
