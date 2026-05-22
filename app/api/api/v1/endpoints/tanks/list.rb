# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class List < Grape::API
    before { authenticate! }

    resource :tanks do
      desc "List tanks (kept only)."
      params do
        optional :truck_id, type: Integer
      end
      get do
        authorize!(::Tank, :index)
        scope = policy_scope(::Tank).order(:plate_number)
        scope = scope.where(truck_id: params[:truck_id]) if params[:truck_id]
        present scope, with: ::API::V1::Entities::Tank
      end
    end
  end
end
