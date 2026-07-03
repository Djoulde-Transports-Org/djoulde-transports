# frozen_string_literal: true

module API::V1::Endpoints::Employees
  class Create < Grape::API
    helpers API::V1::Endpoints::Employees::Common

    helpers do
      def create_employee!
        ::Employees::Create.call(attrs: employee_params, created_by: current_user)
      end
    end

    resource :employees do
      desc "Create an employee."
      params do
        requires :first_name,   type: String, documentation: {desc: "The first name of the employee."}
        requires :last_name,    type: String, documentation: {desc: "The last name of the employee."}
        optional :phone_number, type: String, documentation: {desc: "The phone number of the employee."}
        optional :role, type: String, values: ::Employee.roles.keys,
                        documentation: {desc: "The role of the employee. Defaults to driver."}
        optional :user_id, type: Integer, documentation: {desc: "The ID of the user account to link."}
      end
      post "/create" do
        authorize!(::Employee, :create)
        present create_employee!, with: ::API::V1::Entities::Employee
      end
    end
  end
end
