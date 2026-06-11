# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class List < Grape::API
    resource :trucks do
      desc "List trucks (kept only)."
      paginate per_page: 25, max_per_page: 100
      get do
        authorize!(::Truck, :index)
        present paginate(policy_scope(::Truck).order(:id)), with: ::API::V1::Entities::Truck
      end
    end
  end
end
