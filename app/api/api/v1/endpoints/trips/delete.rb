# frozen_string_literal: true

module API::V1::Endpoints::Trips
  class Delete < Grape::API
    helpers API::V1::Endpoints::Trips::Common

    resource :trips do
      route_param :id, type: Integer do
        desc "Soft-delete a trip (cascades to delivery_note and documents; blocked once billed)."
        delete "/delete" do
          authorize!(trip, :destroy)
          result =
            begin
              ::Trips::Discard.call(trip)
            rescue ApplicationService::HasDependents => error
              unprocessable!(error.message, code: "has_dependents")
            end
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
