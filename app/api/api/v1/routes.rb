# frozen_string_literal: true

module API::V1
  class Routes < Grape::API
    before { authenticate! }

    resource :routes do
      desc "List routes (kept only)."
      get do
        authorize!(::Route, :index)
        present policy_scope(::Route).order(:origin, :destination), with: API::V1::Entities::Route
      end

      desc "Create a route."
      params do
        requires :origin,      type: String
        requires :destination, type: String
        requires :rate,        type: Integer
      end
      post do
        authorize!(::Route, :create)
        route = ::Route.create!(declared(params, include_missing: false))
        present route, with: API::V1::Entities::Route
      end

      route_param :id, type: Integer do
        desc "Get a route."
        get do
          route = find_kept!(::Route)
          authorize!(route, :show)
          present route, with: API::V1::Entities::Route
        end

        desc "Update a route."
        params do
          optional :origin,      type: String
          optional :destination, type: String
          optional :rate,        type: Integer
        end
        patch do
          route = find_kept!(::Route)
          authorize!(route, :update)
          route.update!(declared(params, include_missing: false).except(:id))
          present route, with: API::V1::Entities::Route
        end

        desc "Soft-delete a route (blocked when kept trips reference it)."
        delete do
          route = find_kept!(::Route)
          authorize!(route, :destroy)
          begin
            ::Routes::Discard.call(route)
          rescue ApplicationService::HasDependents => error
            unprocessable!(error.message, code: "has_dependents")
          end
          status 204
          body false
        end
      end
    end
  end
end
