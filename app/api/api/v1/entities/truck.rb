# frozen_string_literal: true

module API::V1::Entities
  class Truck < Base
    expose :id, documentation: {type: "integer", desc: "The ID of the truck."}
    expose :plate_number, documentation: {type: "string", desc: "The plate number of the truck."}
    expose :vin, documentation: {type: "string", desc: "The VIN of the truck."}
    expose :make, documentation: {type: "string", desc: "The make of the truck."}
    expose :model, documentation: {type: "string", desc: "The model of the truck."}
    expose :year, documentation: {type: "integer", desc: "The year of the truck."}
    expose :status, documentation: {type: "string", desc: "The status of the truck."}
    expose :created_by_id, documentation: {type: "integer", desc: "The ID of the user who created the truck."}
    expose :created_at, format_with: :iso_8601_date, documentation: {type: "string", desc: "The creation date (YYYY-MM-DD)."}
    expose :updated_at, format_with: :iso_8601_date, documentation: {type: "string", desc: "The last update date (YYYY-MM-DD)."}
    expose :discarded_at, format_with: :iso_8601_date, documentation: {type: "string", desc: "The discard date (YYYY-MM-DD)."}
  end
end
