# frozen_string_literal: true

module API::V1::Endpoints::Employees
  class List < Grape::API
    resource :employees do
      desc "List employees (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :role, type: String, values: ::Employee.roles.keys,
                        documentation: {desc: "Filter by role (driver, mechanic, dispatcher, manager)."}
        optional :search, type: String,
                          documentation: {desc: "Filter by last name prefix (case-insensitive)."}
      end
      get do
        authorize!(::Employee, :index)
        scope = policy_scope(::Employee).order(:last_name, :first_name)
        scope = scope.where(role: ::Employee.roles[params[:role]]) if params[:role]
        scope = scope.where("last_name LIKE ?", "#{params[:search].upcase}%") if params[:search].present?
        present paginate(scope), with: ::API::V1::Entities::Employee
      end
    end
  end
end
