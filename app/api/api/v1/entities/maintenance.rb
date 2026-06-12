# frozen_string_literal: true

module API::V1::Entities
  class Maintenance < Base
    expose :id,              documentation: {type: "Integer", desc: "The ID of the maintenance record."}
    expose :truck_id,        documentation: {type: "Integer", desc: "The ID of the truck the maintenance was performed on."}
    expose :performed_by_id, documentation: {type: "Integer", desc: "The ID of the user who performed the maintenance."}
    expose :kind,            documentation: {type: "String", desc: "The kind of maintenance."}
    expose :state,           documentation: {type: "String", desc: "The state of the maintenance (started or completed)."}
    expose :performed_on,    format_with: :iso_8601_date, documentation: {type: "Date", desc: "The date the maintenance was performed."}
    expose :cost,            documentation: {type: "Integer", desc: "The total cost of the maintenance (sum of the part prices)."}
    expose :odometer_km,     documentation: {type: "Integer", desc: "The odometer reading in kilometers."}
    expose :estimated_duration, documentation: {type: "BigDecimal", desc: "The estimated number of hours the work takes."}
    expose :actual_duration,    documentation: {type: "BigDecimal", desc: "The actual number of hours the work took, stamped on completion."}
    expose :description,     documentation: {type: "String", desc: "A description of the maintenance."}
    expose :parts, using: ::API::V1::Entities::MaintenancePart, documentation: {type: "Array", desc: "The parts that were changed during the maintenance."} do |maintenance|
      maintenance.parts.kept
    end
  end
end
