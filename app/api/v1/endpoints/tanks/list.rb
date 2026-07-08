# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class List < Grape::API
    helpers do
      def base_tank_scope
        policy_scope(::Tank).order(:plate_number)
      end

      def tank_scope
        base_tank_scope
          .then { |s| params[:truck_id] ? s.where(truck_id: params[:truck_id]) : s }
      end
    end

    resource :tanks do
      desc "List tanks (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :truck_id, type: Integer, documentation: {desc: "Filter tanks by the truck (head) they are attached to."}
      end
      get do
        authorize!(::Tank, :index)
        present paginate(tank_scope), with: ::API::V1::Entities::Tank
      end
    end
  end
end
