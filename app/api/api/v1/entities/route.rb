# frozen_string_literal: true

module API::V1::Entities
  class Route < Base
    expose :id, documentation: {type: "Integer", desc: "The ID of the route."}
    expose :origin, documentation: {type: "String", desc: "The origin of the route."}
    expose :destination, documentation: {type: "String", desc: "The destination of the route."}
    expose :rate, documentation: {type: "Integer", desc: "The rate of the route."}
    expose :created_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The creation time."}
    expose :updated_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The last update time."}
    expose :discarded_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The discard time."}
  end
end
