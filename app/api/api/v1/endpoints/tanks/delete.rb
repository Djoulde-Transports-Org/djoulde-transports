# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Delete < Grape::API
    helpers API::V1::Endpoints::Tanks::Common

    resource :tanks do
      route_param :id, type: Integer do
        desc "Soft-delete a tank (blocked when kept trips reference it)."
        delete "/delete" do
          authorize!(tank, :destroy)
          result =
            begin
              ::Tanks::Discard.call(tank)
            rescue ApplicationService::HasDependents => error
              unprocessable!(error.message, code: "has_dependents")
            end
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
