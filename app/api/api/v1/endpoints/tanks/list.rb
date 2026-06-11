# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class List < Grape::API
    resource :tanks do
      desc "List tanks (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :truck_id, type: Integer, documentation: {desc: "Filter tanks by the truck (head) they are attached to."}
      end
      get do
        authorize!(::Tank, :index)
        scope = policy_scope(::Tank).order(:plate_number)
        scope = scope.where(truck_id: params[:truck_id]) if params[:truck_id]
        present paginate(scope), with: ::API::V1::Entities::Tank
      end
    end
  end
end
