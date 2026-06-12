# frozen_string_literal: true

module API::V1::Endpoints::Documents
  class Delete < Grape::API
    helpers API::V1::Endpoints::Documents::Common

    resource :documents do
      route_param :id, type: Integer do
        desc "Soft-delete a document."
        delete "/delete" do
          authorize!(document, :destroy)
          result = ::Documents::Discard.call(document)
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
