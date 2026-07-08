# frozen_string_literal: true

module API::V1::Endpoints::Trips
  class List < Grape::API
    helpers do
      def trip_scope
        scope = policy_scope(::Trip)
                  .includes(:route, :delivery_note, billing_line_items: :billing_statement,
                            truck: [ :maintenances, :documents, :tank, :driver ])
                  .order("trips.id DESC")

        scope = scope.where(truck_id:  params[:truck_id])  if params[:truck_id]
        scope = scope.where(tank_id:   params[:tank_id])   if params[:tank_id]
        scope = scope.where(route_id:  params[:route_id])  if params[:route_id]
        scope = scope.where(driver_id: params[:driver_id]) if params[:driver_id]
        scope = scope.where(status: ::Trip.statuses[params[:status]]) if params[:status]

        if params[:truck_plate]
          scope = scope.references(:trucks)
                       .where("trucks.plate_number LIKE ?", "#{params[:truck_plate]}%")
        end

        scope = scope.where(scheduled_start_at: params[:date_from].beginning_of_day..) if params[:date_from]
        scope = scope.where(scheduled_start_at: ..params[:date_to].end_of_day)         if params[:date_to]
        scope = scope.where(trips: {id: ...params[:after]})                            if params[:after]

        scope
      end

      def paginate_trips(scope)
        page_size = params[:limit]
        records   = scope.limit(page_size + 1).to_a
        has_more  = records.size > page_size
        records   = records.first(page_size)

        {
          items:       records.map { |r| ::API::V1::Entities::Trip.represent(r).as_json },
          next_cursor: has_more ? records.last&.id : nil,
          has_more:    has_more,
        }
      end
    end

    resource :trips do
      desc "List trips with cursor pagination."
      params do
        optional :truck_id,    type: Integer, documentation: {desc: "Filter by truck ID."}
        optional :tank_id,     type: Integer, documentation: {desc: "Filter by tank ID."}
        optional :route_id,    type: Integer, documentation: {desc: "Filter by route ID."}
        optional :driver_id,   type: Integer, documentation: {desc: "Filter by driver (Employee) ID."}
        optional :status,      type: String, values: ::Trip.statuses.keys,
                               documentation: {desc: "Filter by status."}
        optional :truck_plate, type: String,  documentation: {desc: "Filter by truck plate number prefix (case-sensitive)."}
        optional :date_from,   type: Date,    documentation: {desc: "Return trips with scheduled_start_at on or after this date (YYYY-MM-DD)."}
        optional :date_to,     type: Date,    documentation: {desc: "Return trips with scheduled_start_at on or before this date (YYYY-MM-DD)."}
        optional :after,       type: Integer, documentation: {desc: "Cursor: ID of the last item received. Omit for the first page."}
        optional :limit,       type: Integer, default: 50, values: (1..100),
                               documentation: {desc: "Items per page (1–100, default 50)."}
      end
      get do
        authorize!(::Trip, :index)
        paginate_trips(trip_scope)
      end
    end
  end
end
