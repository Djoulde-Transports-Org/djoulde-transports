# frozen_string_literal: true

module API::V1::Entities
  class Employee < Base
    expose :id,           documentation: {type: "Integer", desc: "The ID of the employee."}
    expose :first_name,   documentation: {type: "String",  desc: "The first name of the employee."}
    expose :last_name,    documentation: {type: "String",  desc: "The last name of the employee."}
    expose :phone_number, documentation: {type: "String",  desc: "The phone number of the employee."}
    expose :role,         documentation: {type: "String",  desc: "The role of the employee (driver, mechanic, dispatcher, manager)."}
    expose :user_id,      documentation: {type: "Integer", desc: "The ID of the linked user account, if any."}
    expose :created_at,   format_with: :iso_8601,      documentation: {type: "DateTime", desc: "The creation time."}
    expose :updated_at,   format_with: :iso_8601,      documentation: {type: "DateTime", desc: "The last update time."}
    expose :discarded_at, format_with: :iso_8601,      documentation: {type: "DateTime", desc: "The discard time."}
  end
end
