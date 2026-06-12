# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  class List < Grape::API
    resource :maintenances do
      desc "List maintenances (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :truck_id, type: Integer, documentation: {desc: "Filter maintenances by truck."}
        optional :kind,     type: String, values: ::Maintenance.kinds.keys, documentation: {desc: "Filter maintenances by kind."}
      end
      get do
        authorize!(::Maintenance, :index)
        scope = policy_scope(::Maintenance).order(performed_on: :desc)
        scope = scope.where(truck_id: params[:truck_id])           if params[:truck_id]
        scope = scope.where(kind: ::Maintenance.kinds[params[:kind]]) if params[:kind]
        present paginate(scope), with: ::API::V1::Entities::Maintenance
      end
    end
  end
end
