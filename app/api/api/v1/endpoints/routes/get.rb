# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class Get < Grape::API
    helpers API::V1::Endpoints::Routes::Common

    resource :routes do
      route_param :id, type: Integer do
        desc "Get a route."
        get do
          authorize!(route_record, :show)
          present route_record, with: ::API::V1::Entities::Route
        end
      end
    end
  end
end
