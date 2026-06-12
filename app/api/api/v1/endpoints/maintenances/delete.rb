# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  class Delete < Grape::API
    helpers API::V1::Endpoints::Maintenances::Common

    resource :maintenances do
      route_param :id, type: Integer do
        desc "Soft-delete a maintenance record (cascades to documents)."
        delete "/delete" do
          authorize!(maintenance, :destroy)
          result = ::Maintenances::Discard.call(maintenance)
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
