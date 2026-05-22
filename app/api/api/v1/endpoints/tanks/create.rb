# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Create < Grape::API
    before { authenticate! }

    resource :tanks do
      desc "Create a tank attached to a head (truck)."
      params do
        requires :truck_id,        type: Integer
        requires :plate_number,    type: String
        requires :capacity_liters, type: Integer
        optional :vin,             type: String
        optional :make,            type: String
        optional :model,           type: String
        optional :year,            type: Integer
        optional :status,          type: String, values: ::Tank.statuses.keys
      end
      post "/create" do
        authorize!(::Tank, :create)
        tank = ::Tank.new(declared(params, include_missing: false))
        tank.save!
        present tank, with: ::API::V1::Entities::Tank
      end
    end
  end
end
