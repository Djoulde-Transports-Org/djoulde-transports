# frozen_string_literal: true

module API::V1::Endpoints::Documents
  class Get < Grape::API
    helpers API::V1::Endpoints::Documents::Common

    resource :documents do
      route_param :id, type: Integer do
        desc "Get a document."
        get do
          authorize!(document, :show)
          present document, with: ::API::V1::Entities::Document
        end
      end
    end
  end
end
