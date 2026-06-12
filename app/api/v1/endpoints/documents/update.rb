# frozen_string_literal: true

module API::V1::Endpoints::Documents
  class Update < Grape::API
    helpers API::V1::Endpoints::Documents::Common

    helpers do
      def update_document!
        document.update!(document_params)
        attach_file_if_present(document)
        document
      end
    end

    resource :documents do
      route_param :id, type: Integer do
        desc "Update a document."
        params do
          optional :number,     type: String, documentation: {desc: "The document number."}
          optional :title,      type: String, documentation: {desc: "The title of the document."}
          optional :doc_type,   type: String, values: ::Document.doc_types.keys, documentation: {desc: "The kind of document."}
          optional :issued_on,  type: Date, documentation: {desc: "The date the document was issued."}
          optional :expires_on, type: Date, documentation: {desc: "The date the document expires."}
          optional :file,       type: Rack::Multipart::UploadedFile, documentation: {desc: "The uploaded file."}
        end
        patch "/update" do
          authorize!(document, :update)

          present update_document!, with: ::API::V1::Entities::Document
        end
      end
    end
  end
end
