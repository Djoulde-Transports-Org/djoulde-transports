# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class Create < Grape::API
    helpers API::V1::Endpoints::Routes::Common

    helpers do
      def create_route
        route = ::Route.new(route_params)
        route.save!
        route
      end
    end

    resource :routes do
      desc "Create a route."
      params do
        requires :origin,      type: String,  documentation: {desc: "The origin of the route."}
        requires :destination, type: String,  documentation: {desc: "The destination of the route."}
        requires :rate,        type: Integer, documentation: {desc: "The rate of the route."}
      end
      post "/create" do
        authorize!(::Route, :create)

        present create_route, with: ::API::V1::Entities::Route
      end
    end
  end
end
