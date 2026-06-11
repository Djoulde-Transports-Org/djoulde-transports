# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class Delete < Grape::API
    helpers API::V1::Endpoints::Routes::Common

    resource :routes do
      route_param :id, type: Integer do
        desc "Soft-delete a route (blocked when kept trips reference it)."
        delete "/delete" do
          authorize!(route_record, :destroy)
          result =
            begin
              ::Routes::Discard.call(route_record)
            rescue ApplicationService::HasDependents => error
              unprocessable!(error.message, code: "has_dependents")
            end
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
