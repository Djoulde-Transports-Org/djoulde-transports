# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  class Get < Grape::API
    helpers API::V1::Endpoints::Maintenances::Common

    resource :maintenances do
      route_param :id, type: Integer do
        desc "Get a maintenance record."
        get do
          authorize!(maintenance, :show)
          present maintenance, with: ::API::V1::Entities::Maintenance
        end
      end
    end
  end
end
