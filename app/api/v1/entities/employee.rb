# frozen_string_literal: true

module API::V1::Entities
  class Employee < Base
    expose :id,           documentation: {type: "Integer", desc: "The ID of the employee."}
    expose :first_name,   documentation: {type: "String",  desc: "The first name of the employee."}
    expose :last_name,    documentation: {type: "String",  desc: "The last name of the employee."}
    expose :full_name,    documentation: {type: "String",  desc: "The employee's first and last name combined."} do |employee, _opts|
      "#{employee.first_name} #{employee.last_name}"
    end
    expose :phone_number, documentation: {type: "String",  desc: "The phone number of the employee."}
    expose :address,      documentation: {type: "String",  desc: "The home address of the employee."}
    expose :hire_date,    format_with: :iso_8601_date, documentation: {type: "String", desc: "The date the employee was hired."}
    expose :role,         documentation: {type: "String",  desc: "The role of the employee (driver, mechanic, dispatcher, manager)."}
    expose :status,       documentation: {type: "String",  desc: "The status of the employee (active, on_leave, inactive)."}
    expose :user_id,      documentation: {type: "Integer", desc: "The ID of the linked user account, if any."}
    expose :assigned_truck, documentation: {type: "Object", desc: "The truck assigned to this employee, if any."} do |employee, _opts|
      next nil unless employee.truck

      {id: employee.truck.id, plate_number: employee.truck.plate_number}
    end
  end
end
