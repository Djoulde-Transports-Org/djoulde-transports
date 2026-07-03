# frozen_string_literal: true

module API::V1::Endpoints::Employees
  class Update < Grape::API
    helpers API::V1::Endpoints::Employees::Common

    helpers do
      def update_employee!
        ::Employees::Update.call(employee, attrs: employee_params)
      end
    end

    resource :employees do
      route_param :id, type: Integer do
        desc "Update an employee."
        params do
          optional :first_name,   type: String, documentation: {desc: "The first name of the employee."}
          optional :last_name,    type: String, documentation: {desc: "The last name of the employee."}
          optional :phone_number, type: String, documentation: {desc: "The phone number of the employee."}
          optional :role, type: String, values: ::Employee.roles.keys,
                          documentation: {desc: "The role of the employee."}
          optional :user_id, type: Integer, documentation: {desc: "The ID of the user account to link. Pass null to unlink."}
        end
        patch "/update" do
          authorize!(employee, :update)
          update_employee!
          present employee.reload, with: ::API::V1::Entities::Employee
        end
      end
    end
  end
end
