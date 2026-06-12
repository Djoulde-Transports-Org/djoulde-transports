# frozen_string_literal: true

module API::V1::Endpoints::Documents
  class List < Grape::API
    resource :documents do
      desc "List documents (kept only). Filter by documentable_type / documentable_id."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :documentable_type, type: String, values: Common::DOCUMENTABLE_TYPES, documentation: {desc: "Filter documents by owner type."}
        optional :documentable_id,   type: Integer, documentation: {desc: "Filter documents by owner id."}
        optional :doc_type,          type: String, values: ::Document.doc_types.keys, documentation: {desc: "Filter documents by kind."}
      end
      get do
        authorize!(::Document, :index)
        scope = policy_scope(::Document).order(created_at: :desc)
        scope = scope.where(documentable_type: params[:documentable_type])     if params[:documentable_type]
        scope = scope.where(documentable_id: params[:documentable_id])         if params[:documentable_id]
        scope = scope.where(doc_type: ::Document.doc_types[params[:doc_type]]) if params[:doc_type]
        present paginate(scope), with: ::API::V1::Entities::Document
      end
    end
  end
end
