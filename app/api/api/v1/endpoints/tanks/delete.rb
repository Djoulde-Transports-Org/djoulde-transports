# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Delete < Grape::API
    before { authenticate! }

    resource :tanks do
      route_param :id, type: Integer do
        desc "Soft-delete a tank (blocked when kept trips reference it)."
        delete "/delete" do
          tank = find_kept!(::Tank)
          authorize!(tank, :destroy)
          begin
            ::Tanks::Discard.call(tank)
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
