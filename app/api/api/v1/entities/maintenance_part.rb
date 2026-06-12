# frozen_string_literal: true

module API::V1::Entities
  class MaintenancePart < Base
    expose :id,         documentation: {type: "Integer", desc: "The ID of the part."}
    expose :name,       documentation: {type: "String", desc: "The name of the part that was changed."}
    expose :price,      documentation: {type: "Integer", desc: "The price of the part."}
  end
end
