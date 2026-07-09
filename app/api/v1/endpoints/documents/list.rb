# frozen_string_literal: true

module API::V1::Endpoints::Documents
  class List < Grape::API
    helpers do
      def base_document_scope
        policy_scope(::Document).order("documents.id DESC")
      end

      def document_scope
        base_document_scope
          .then { |s| params[:documentable_type] ? s.where(documentable_type: params[:documentable_type])              : s }
          .then { |s| params[:documentable_id]   ? s.where(documentable_id: params[:documentable_id])                 : s }
          .then { |s| params[:doc_type]          ? s.where(doc_type: ::Document.doc_types[params[:doc_type]])         : s }
          .then { |s| params[:date_from]         ? s.where(issued_on: params[:date_from]..)                           : s }
          .then { |s| params[:date_to]           ? s.where(issued_on: ..params[:date_to])                             : s }
          .then { |s| params[:search].present?   ? s.where("title LIKE ?", "#{params[:search]}%")                    : s }
          .then { |s| params[:after]             ? s.where(documents: {id: ...params[:after]})                        : s }
      end

      def paginate_documents(scope)
        page_size = params[:limit]
        records   = scope.limit(page_size + 1).to_a
        has_more  = records.size > page_size
        records   = records.first(page_size)

        {
          items:       records.map { |r| ::API::V1::Entities::Document.represent(r).as_json },
          next_cursor: has_more ? records.last&.id : nil,
          has_more:    has_more,
        }
      end
    end

    resource :documents do
      desc "List documents (kept only). Filter by documentable_type / documentable_id."
      params do
        optional :documentable_type, type: String,  values: Common::DOCUMENTABLE_TYPES,
                                     documentation: {desc: "Filter documents by owner type."}
        optional :documentable_id,   type: Integer, documentation: {desc: "Filter documents by owner id."}
        optional :doc_type,          type: String,  values: ::Document.doc_types.keys,
                                     documentation: {desc: "Filter documents by kind."}
        optional :date_from,         type: Date,    documentation: {desc: "Return documents with issued_on on or after this date (YYYY-MM-DD)."}
        optional :date_to,           type: Date,    documentation: {desc: "Return documents with issued_on on or before this date (YYYY-MM-DD)."}
        optional :search,            type: String,  documentation: {desc: "Filter by title prefix."}
        optional :after,             type: Integer, documentation: {desc: "Cursor: ID of the last item received. Omit for the first page."}
        optional :limit,             type: Integer, default: 50, values: (1..100),
                                     documentation: {desc: "Items per page (1–100, default 50)."}
      end
      get do
        authorize!(::Document, :index)
        paginate_documents(document_scope)
      end
    end
  end
end
