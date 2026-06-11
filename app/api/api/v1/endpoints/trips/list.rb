# frozen_string_literal: true

module API::V1::Endpoints::Trips
  class List < Grape::API
    resource :trips do
      desc "List trips (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :truck_id, type: Integer, documentation: {desc: "Filter trips by truck."}
        optional :tank_id,  type: Integer, documentation: {desc: "Filter trips by tank."}
        optional :route_id, type: Integer, documentation: {desc: "Filter trips by route."}
        optional :status,   type: String, values: ::Trip.statuses.keys, documentation: {desc: "Filter trips by status."}
      end
      get do
        authorize!(::Trip, :index)
        scope = policy_scope(::Trip).order(scheduled_start_at: :desc)
        scope = scope.where(truck_id: params[:truck_id]) if params[:truck_id]
        scope = scope.where(tank_id: params[:tank_id])   if params[:tank_id]
        scope = scope.where(route_id: params[:route_id]) if params[:route_id]
        scope = scope.where(status: ::Trip.statuses[params[:status]]) if params[:status]
        present paginate(scope), with: ::API::V1::Entities::Trip
      end
    end
  end
end
