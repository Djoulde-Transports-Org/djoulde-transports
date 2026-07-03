# frozen_string_literal: true

module API::V1::Endpoints::Employees
  class Get < Grape::API
    helpers API::V1::Endpoints::Employees::Common

    resource :employees do
      route_param :id, type: Integer do
        desc "Get an employee by ID."
        get do
          authorize!(employee, :show)
          present employee, with: ::API::V1::Entities::Employee
        end
      end
    end
  end
end
