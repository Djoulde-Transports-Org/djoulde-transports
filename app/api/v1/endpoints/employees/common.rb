# frozen_string_literal: true

module API::V1::Endpoints::Employees
  module Common
    extend Grape::API::Helpers

    def employee
      @employee ||= begin
        record = policy_scope(::Employee).kept
                   .includes(:documents)
                   .find_by(id: params[:id])
        not_found!(message: "Employee not found.") unless record
        record
      end
    end

    def employee_params
      declared(params, include_missing: false).except(:id)
    end
  end
end
