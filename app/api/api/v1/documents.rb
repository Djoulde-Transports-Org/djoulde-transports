# frozen_string_literal: true

module API::V1
  class Documents < Grape::API
    DOCUMENTABLE_TYPES = %w(Truck Trip Maintenance BillingStatement).freeze

    before { authenticate! }

    helpers do
      def document_attrs
        declared(params, include_missing: false).slice(
          :doc_type, :title, :issued_on, :expires_on, :documentable_type, :documentable_id
        )
      end

      def attach_file_if_present(document)
        return if params[:file].blank?

        document.file.attach(
          io: params[:file][:tempfile],
          filename: params[:file][:filename],
          content_type: params[:file][:type]
        )
      end
    end

    resource :documents do
      desc "List documents (kept only). Filter by documentable_type / documentable_id."
      params do
        optional :documentable_type, type: String, values: DOCUMENTABLE_TYPES
        optional :documentable_id,   type: Integer
        optional :doc_type,          type: String, values: ::Document.doc_types.keys
      end
      get do
        authorize!(::Document, :index)
        scope = policy_scope(::Document).order(created_at: :desc)
        scope = scope.where(documentable_type: params[:documentable_type]) if params[:documentable_type]
        scope = scope.where(documentable_id: params[:documentable_id])     if params[:documentable_id]
        scope = scope.where(doc_type: ::Document.doc_types[params[:doc_type]]) if params[:doc_type]
        present scope, with: API::V1::Entities::Document
      end

      desc "Create a document. Polymorphic owner via documentable_type + documentable_id."
      params do
        requires :documentable_type, type: String, values: DOCUMENTABLE_TYPES
        requires :documentable_id,   type: Integer
        requires :title,             type: String
        optional :doc_type,          type: String, values: ::Document.doc_types.keys
        optional :issued_on,         type: Date
        optional :expires_on,        type: Date
        optional :file,              type: Rack::Multipart::UploadedFile
      end
      post do
        authorize!(::Document, :create)
        document = ::Document.new(document_attrs)
        document.uploaded_by = current_user
        attach_file_if_present(document)
        document.save!
        present document, with: API::V1::Entities::Document
      end

      route_param :id, type: Integer do
        desc "Get a document."
        get do
          document = find_kept!(::Document)
          authorize!(document, :show)
          present document, with: API::V1::Entities::Document
        end

        desc "Update a document."
        params do
          optional :title,      type: String
          optional :doc_type,   type: String, values: ::Document.doc_types.keys
          optional :issued_on,  type: Date
          optional :expires_on, type: Date
          optional :file,       type: Rack::Multipart::UploadedFile
        end
        patch do
          document = find_kept!(::Document)
          authorize!(document, :update)
          document.update!(declared(params, include_missing: false).slice(
            :title, :doc_type, :issued_on, :expires_on
          ))
          attach_file_if_present(document)
          present document, with: API::V1::Entities::Document
        end

        desc "Soft-delete a document."
        delete do
          document = find_kept!(::Document)
          authorize!(document, :destroy)
          ::Documents::Discard.call(document)
          status 204
          body false
        end
      end
    end
  end
end
