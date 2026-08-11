# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  class Update < Grape::API
    helpers API::V1::Endpoints::Maintenances::Common

    helpers do
      def update_maintenance!
        ::Maintenances::Update.call(maintenance, maintenance_params, parts_params)
      end
    end

    resource :maintenances do
      route_param :id, type: Integer do
        desc "Update a maintenance record. Supplying `parts` replaces the existing set."
        params do
          optional :truck_id,        type: Integer, documentation: {desc: "The truck the maintenance was performed on."}
          optional :performed_on,    type: Date, documentation: {desc: "The date the maintenance was performed."}
          optional :performed_by_id, type: Integer, documentation: {desc: "The user who performed the maintenance."}
          optional :kind,               type: String, documentation: {desc: "The kind of maintenance. An unrecognized name creates a new maintenance kind."}
          optional :state,              type: String, values: ::Maintenance.states.keys, documentation: {desc: "The state of the maintenance. Setting it to completed stamps the actual duration and frees the truck."}
          optional :odometer_km,        type: Integer, documentation: {desc: "The odometer reading in kilometers."}
          optional :estimated_duration, type: BigDecimal, documentation: {desc: "The estimated number of hours the work takes."}
          optional :description,     type: String, documentation: {desc: "A description of the maintenance."}
          optional :parts, type: Array, documentation: {desc: "Replaces the parts that were changed during the maintenance."} do
            requires :name,  type: String, documentation: {desc: "The name of the part."}
            optional :price, type: Integer, default: 0, documentation: {desc: "The price of the part."}
          end
        end
        patch "/update" do
          authorize!(maintenance, :update)

          present update_maintenance!, with: ::API::V1::Entities::Maintenance
        end
      end
    end
  end
end
