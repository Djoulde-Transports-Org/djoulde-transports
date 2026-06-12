# frozen_string_literal: true

module API::V1::Endpoints::Documents
  class Create < Grape::API
    helpers API::V1::Endpoints::Documents::Common

    helpers do
      def create_document!
        document = ::Document.new(document_params)
        document.uploaded_by = current_user
        attach_file_if_present(document)
        document.save!
        document
      end
    end

    resource :documents do
      desc "Create a document. Polymorphic owner via documentable_type + documentable_id."
      params do
        requires :documentable_type, type: String, values: Common::DOCUMENTABLE_TYPES, documentation: {desc: "The type of the document's owner."}
        requires :documentable_id,   type: Integer, documentation: {desc: "The id of the document's owner."}
        requires :number,            type: String, documentation: {desc: "The document number."}
        requires :title,             type: String, documentation: {desc: "The title of the document."}
        optional :doc_type,          type: String, values: ::Document.doc_types.keys, documentation: {desc: "The kind of document."}
        optional :issued_on,         type: Date, documentation: {desc: "The date the document was issued."}
        optional :expires_on,        type: Date, documentation: {desc: "The date the document expires."}
        optional :file,              type: Rack::Multipart::UploadedFile, documentation: {desc: "The uploaded file."}
      end
      post "/create" do
        authorize!(::Document, :create)

        present create_document!, with: ::API::V1::Entities::Document
      end
    end
  end
end
