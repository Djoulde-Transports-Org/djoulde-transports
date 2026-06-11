# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class Update < Grape::API
    helpers API::V1::Endpoints::Routes::Common

    helpers do
      def update_route!
        route_record.update!(route_params)
      end
    end

    resource :routes do
      route_param :id, type: Integer do
        desc "Update a route."
        params do
          optional :origin,      type: String,  documentation: {desc: "The origin of the route."}
          optional :destination, type: String,  documentation: {desc: "The destination of the route."}
          optional :rate,        type: Integer, documentation: {desc: "The rate of the route."}
        end
        patch "/update" do
          authorize!(route_record, :update)
          update_route!

          present route_record, with: ::API::V1::Entities::Route
        end
      end
    end
  end
end
