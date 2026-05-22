# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Delete < Grape::API
    before { authenticate! }

    resource :trucks do
      route_param :id, type: Integer do
        desc "Soft-delete a truck (cascades to trips, maintenances, documents)."
        delete do
          truck = find_kept!(::Truck)
          authorize!(truck, :destroy)
          begin
            ::Trucks::Discard.call(truck)
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
