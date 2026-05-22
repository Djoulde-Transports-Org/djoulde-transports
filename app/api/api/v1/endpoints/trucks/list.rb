# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class List < Grape::API
    before { authenticate! }

    resource :trucks do
      desc "List trucks (kept only)."
      get do
        authorize!(::Truck, :index)
        present policy_scope(::Truck).order(:plate_number), with: ::API::V1::Entities::Truck
      end
    end
  end
end
