# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  class Create < Grape::API
    helpers API::V1::Endpoints::Maintenances::Common

    helpers do
      def create_maintenance
        ::Maintenances::Create.call(maintenance_params, parts_params)
      end
    end

    resource :maintenances do
      desc "Create a maintenance record together with the parts that were changed."
      params do
        requires :truck_id,        type: Integer, documentation: {desc: "The truck the maintenance was performed on."}
        requires :performed_on,    type: Date, documentation: {desc: "The date the maintenance was performed."}
        optional :performed_by_id, type: Integer, documentation: {desc: "The user who performed the maintenance."}
        optional :kind,            type: String, documentation: {desc: "The kind of maintenance. An unrecognized name creates a new maintenance kind."}
        optional :odometer_km,        type: Integer, documentation: {desc: "The odometer reading in kilometers."}
        optional :estimated_duration, type: BigDecimal, documentation: {desc: "The estimated number of hours the work takes."}
        optional :description,     type: String, documentation: {desc: "A description of the maintenance."}
        optional :parts, type: Array, documentation: {desc: "The parts that were changed during the maintenance."} do
          requires :name,  type: String, documentation: {desc: "The name of the part."}
          optional :price, type: Integer, default: 0, documentation: {desc: "The price of the part."}
        end
      end
      post "/create" do
        authorize!(::Maintenance, :create)

        present create_maintenance, with: ::API::V1::Entities::Maintenance
      end
    end
  end
end
