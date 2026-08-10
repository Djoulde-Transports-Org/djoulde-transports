# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  class List < Grape::API
    helpers do
      def base_maintenance_scope
        policy_scope(::Maintenance)
          .includes(:parts, :truck, performed_by: :employee)
          .order("maintenances.id DESC")
      end

      def maintenance_scope
        base_maintenance_scope
          .then { |s| params[:truck_id]  ? s.where(truck_id: params[:truck_id])                : s }
          .then { |s| params[:kind]      ? s.where(kind: ::Maintenance.kinds[params[:kind]])    : s }
          .then { |s| params[:state]     ? s.where(state: ::Maintenance.states[params[:state]]): s }
          .then { |s| params[:date_from] ? s.where(performed_on: params[:date_from]..)         : s }
          .then { |s| params[:date_to]   ? s.where(performed_on: ..params[:date_to])           : s }
          .then { |s| params[:after]     ? s.where(maintenances: {id: ...params[:after]})      : s }
          .then { |s| params[:search].present? ? s.joins(:truck).where(
            "trucks.plate_number LIKE :q OR maintenances.description LIKE :q", q: "%#{params[:search]}%"
          ) : s }
      end

      def paginate_maintenances(scope)
        page_size = params[:limit]
        records   = scope.limit(page_size + 1).to_a
        has_more  = records.size > page_size
        records   = records.first(page_size)

        {
          items:       records.map { |r| ::API::V1::Entities::Maintenance.represent(r).as_json },
          next_cursor: has_more ? records.last&.id : nil,
          has_more:    has_more,
        }
      end
    end

    resource :maintenances do
      desc "List maintenances with cursor pagination."
      params do
        optional :truck_id,  type: Integer, documentation: {desc: "Filter by truck ID."}
        optional :kind,      type: String,  values: ::Maintenance.kinds.keys,
                             documentation: {desc: "Filter by kind."}
        optional :state,     type: String,  values: ::Maintenance.states.keys,
                             documentation: {desc: "Filter by state (started / completed)."}
        optional :date_from, type: Date,    documentation: {desc: "Return maintenances with performed_on on or after this date (YYYY-MM-DD)."}
        optional :date_to,   type: Date,    documentation: {desc: "Return maintenances with performed_on on or before this date (YYYY-MM-DD)."}
        optional :search,    type: String,  documentation: {desc: "Filter by truck plate number or description (substring match)."}
        optional :after,     type: Integer, documentation: {desc: "Cursor: ID of the last item received. Omit for the first page."}
        optional :limit,     type: Integer, default: 50, values: (1..100),
                             documentation: {desc: "Items per page (1–100, default 50)."}
      end
      get do
        authorize!(::Maintenance, :index)
        paginate_maintenances(maintenance_scope)
      end
    end
  end
end
