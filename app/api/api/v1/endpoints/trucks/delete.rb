# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Delete < Grape::API
    helpers API::V1::Endpoints::Trucks::Common

    resource :trucks do
      route_param :id, type: Integer do
        desc "Soft-delete a truck (cascades to trips, maintenances, documents)."
        delete "/delete" do
          authorize!(truck, :destroy)
          result =
            begin
              ::Trucks::Discard.call(truck)
            rescue ApplicationService::HasDependents => error
              unprocessable!(error.message, code: "has_dependents")
            end
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
