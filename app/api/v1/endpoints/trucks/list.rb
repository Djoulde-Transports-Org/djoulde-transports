# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class List < Grape::API
    resource :trucks do
      desc "List trucks (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :status, type: String, values: ::Truck.statuses.keys,
                          documentation: {desc: "Filter by truck status (ready, in_maintenance, on_trip)."}
        optional :search, type: String,
                          documentation: {desc: "Filter by plate number prefix (case-insensitive)."}
      end
      get do
        authorize!(::Truck, :index)
        scope = policy_scope(::Truck)
          .includes(:tank, :maintenances, :documents)
          .order(:id)
        scope = scope.where(status: ::Truck.statuses[params[:status]]) if params[:status]
        scope = scope.where("plate_number LIKE ?", "#{params[:search].upcase}%") if params[:search].present?
        present paginate(scope), with: ::API::V1::Entities::Truck
      end
    end
  end
end
