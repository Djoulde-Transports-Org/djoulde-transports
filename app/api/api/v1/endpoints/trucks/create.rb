# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Create < Grape::API
    before { authenticate! }

    resource :trucks do
      desc "Create a truck."
      params do
        requires :plate_number, type: String
        requires :vin,          type: String
        requires :make,         type: String
        requires :model,        type: String
        requires :year,         type: Integer
        optional :status,       type: String, values: ::Truck.statuses.keys
      end
      post do
        authorize!(::Truck, :create)
        truck = ::Truck.new(declared(params, include_missing: false))
        truck.created_by = current_user
        truck.save!
        present truck, with: ::API::V1::Entities::Truck
      end
    end
  end
end
