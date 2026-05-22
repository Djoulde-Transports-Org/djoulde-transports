# frozen_string_literal: true

module API::V1
  class Trips < Grape::API
    before { authenticate! }

    helpers do
      def trip_params
        declared(params, include_missing: false).except(:id)
      end
    end

    resource :trips do
      desc "List trips (kept only)."
      params do
        optional :truck_id, type: Integer
        optional :tank_id,  type: Integer
        optional :route_id, type: Integer
        optional :status,   type: String, values: ::Trip.statuses.keys
      end
      get do
        authorize!(::Trip, :index)
        scope = policy_scope(::Trip).order(scheduled_start_at: :desc)
        scope = scope.where(truck_id: params[:truck_id]) if params[:truck_id]
        scope = scope.where(tank_id: params[:tank_id])   if params[:tank_id]
        scope = scope.where(route_id: params[:route_id]) if params[:route_id]
        scope = scope.where(status: ::Trip.statuses[params[:status]]) if params[:status]
        present scope, with: API::V1::Entities::Trip
      end

      desc "Create a trip."
      params do
        requires :truck_id, type: Integer
        requires :route_id, type: Integer
        optional :tank_id,            type: Integer, desc: "Defaults to the truck's currently paired tank."
        optional :driver_id,          type: Integer
        optional :status,             type: String, values: ::Trip.statuses.keys
        optional :scheduled_start_at, type: DateTime
        optional :scheduled_end_at,   type: DateTime
        optional :actual_start_at,    type: DateTime
        optional :actual_end_at,      type: DateTime
        optional :cargo_description,  type: String
        optional :distance_km,        type: BigDecimal
      end
      post do
        authorize!(::Trip, :create)
        trip = ::Trip.create!(trip_params)
        present trip, with: API::V1::Entities::Trip
      end

      route_param :id, type: Integer do
        desc "Get a trip."
        get do
          trip = find_kept!(::Trip)
          authorize!(trip, :show)
          present trip, with: API::V1::Entities::Trip
        end

        desc "Update a trip."
        params do
          optional :truck_id,           type: Integer
          optional :tank_id,            type: Integer
          optional :route_id,           type: Integer
          optional :driver_id,          type: Integer
          optional :status,             type: String, values: ::Trip.statuses.keys
          optional :scheduled_start_at, type: DateTime
          optional :scheduled_end_at,   type: DateTime
          optional :actual_start_at,    type: DateTime
          optional :actual_end_at,      type: DateTime
          optional :cargo_description,  type: String
          optional :distance_km,        type: BigDecimal
        end
        patch do
          trip = find_kept!(::Trip)
          authorize!(trip, :update)
          trip.update!(trip_params)
          present trip, with: API::V1::Entities::Trip
        end

        desc "Soft-delete a trip (cascades to delivery_note, documents)."
        delete do
          trip = find_kept!(::Trip)
          authorize!(trip, :destroy)
          begin
            ::Trips::Discard.call(trip)
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
