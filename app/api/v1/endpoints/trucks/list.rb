# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class List < Grape::API
    helpers do
      def base_truck_scope
        policy_scope(::Truck)
          .includes(:tank, :maintenances, :documents)
          .order(:id)
      end

      def truck_scope
        base_truck_scope
          .then { |s| params[:status]          ? s.where(status: ::Truck.statuses[params[:status]])                   : s }
          .then { |s| params[:search].present? ? s.where("plate_number LIKE ?", "#{params[:search].upcase}%")         : s }
      end
    end

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
        present paginate(truck_scope), with: ::API::V1::Entities::Truck
      end
    end
  end
end
