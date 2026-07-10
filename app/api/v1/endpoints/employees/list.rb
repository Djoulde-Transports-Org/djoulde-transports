# frozen_string_literal: true

module API::V1::Endpoints::Employees
  class List < Grape::API
    helpers do
      def base_employee_scope
        policy_scope(::Employee).order(:last_name, :first_name)
      end

      def employee_scope
        base_employee_scope
          .then { |s| params[:role]            ? s.where(role: ::Employee.roles[params[:role]])                                                                                      : s }
          .then { |s| params[:search].present? ? s.where("last_name LIKE ? OR first_name LIKE ?", "#{params[:search].upcase}%", "#{params[:search].upcase}%") : s }
      end
    end

    resource :employees do
      desc "List employees (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :role,   type: String, values: ::Employee.roles.keys,
                          documentation: {desc: "Filter by role (driver, mechanic, dispatcher, manager)."}
        optional :search, type: String,
                          documentation: {desc: "Filter by last name or first name prefix (case-insensitive)."}
      end
      get do
        authorize!(::Employee, :index)
        present paginate(employee_scope), with: ::API::V1::Entities::Employee
      end
    end
  end
end
