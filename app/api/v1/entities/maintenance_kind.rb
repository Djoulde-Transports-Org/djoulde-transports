# frozen_string_literal: true

module API::V1::Entities
  class MaintenanceKind < Base
    expose :id,   documentation: {type: "Integer", desc: "The ID of the maintenance kind."}
    expose :name, documentation: {type: "String",  desc: "The name of the maintenance kind."}
  end
end
