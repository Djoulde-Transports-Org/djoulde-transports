# frozen_string_literal: true

module API::V1
  class Maintenances < Grape::API
    before { authenticate! }

    helpers do
      def maintenance_params
        declared(params, include_missing: false).except(:id)
      end
    end

    resource :maintenances do
      desc "List maintenances (kept only)."
      params do
        optional :truck_id, type: Integer
        optional :kind,     type: String, values: ::Maintenance.kinds.keys
      end
      get do
        authorize!(::Maintenance, :index)
        scope = policy_scope(::Maintenance).order(performed_on: :desc)
        scope = scope.where(truck_id: params[:truck_id]) if params[:truck_id]
        scope = scope.where(kind: ::Maintenance.kinds[params[:kind]]) if params[:kind]
        present scope, with: API::V1::Entities::Maintenance
      end

      desc "Create a maintenance record."
      params do
        requires :truck_id,        type: Integer
        requires :performed_on,    type: Date
        optional :performed_by_id, type: Integer
        optional :kind,            type: String, values: ::Maintenance.kinds.keys
        optional :cost,            type: Integer
        optional :odometer_km,     type: Integer
        optional :description,     type: String
      end
      post do
        authorize!(::Maintenance, :create)
        maintenance = ::Maintenance.create!(maintenance_params)
        present maintenance, with: API::V1::Entities::Maintenance
      end

      route_param :id, type: Integer do
        desc "Get a maintenance record."
        get do
          maintenance = find_kept!(::Maintenance)
          authorize!(maintenance, :show)
          present maintenance, with: API::V1::Entities::Maintenance
        end

        desc "Update a maintenance record."
        params do
          optional :truck_id,        type: Integer
          optional :performed_on,    type: Date
          optional :performed_by_id, type: Integer
          optional :kind,            type: String, values: ::Maintenance.kinds.keys
          optional :cost,            type: Integer
          optional :odometer_km,     type: Integer
          optional :description,     type: String
        end
        patch do
          maintenance = find_kept!(::Maintenance)
          authorize!(maintenance, :update)
          maintenance.update!(maintenance_params)
          present maintenance, with: API::V1::Entities::Maintenance
        end

        desc "Soft-delete a maintenance record (cascades to documents)."
        delete do
          maintenance = find_kept!(::Maintenance)
          authorize!(maintenance, :destroy)
          ::Maintenances::Discard.call(maintenance)
          status 204
          body false
        end
      end
    end
  end
end
