# frozen_string_literal: true

module API::V1::Endpoints::Employees
  class Delete < Grape::API
    helpers API::V1::Endpoints::Employees::Common

    resource :employees do
      route_param :id, type: Integer do
        desc "Soft-delete an employee (cascades to documents, clears truck assignment)."
        delete "/delete" do
          authorize!(employee, :destroy)
          result = ::Employees::Discard.call(employee)
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
