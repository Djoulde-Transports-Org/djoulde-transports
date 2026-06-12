# frozen_string_literal: true

module API::V1::Entities
  class Document < Base
    expose :id,                documentation: {type: "Integer", desc: "The ID of the document."}
    expose :documentable_type, documentation: {type: "String", desc: "The type of the document's owner."}
    expose :documentable_id,   documentation: {type: "Integer", desc: "The id of the document's owner."}
    expose :doc_type,          documentation: {type: "String", desc: "The kind of document."}
    expose :number,            documentation: {type: "String", desc: "The document number."}
    expose :title,             documentation: {type: "String", desc: "The title of the document."}
    expose :issued_on,         format_with: :iso_8601_date, documentation: {type: "Date", desc: "The date the document was issued."}
    expose :expires_on,        format_with: :iso_8601_date, documentation: {type: "Date", desc: "The date the document expires."}
    expose :uploaded_by_id,    documentation: {type: "Integer", desc: "The ID of the user who uploaded the document."}
    expose :file_attached, documentation: {type: "Boolean", desc: "Whether a file is attached to the document."} do |document|
      document.file.attached?
    end
    expose :created_at,   format_with: :iso_8601, documentation: {type: "DateTime", desc: "The creation time."}
    expose :updated_at,   format_with: :iso_8601, documentation: {type: "DateTime", desc: "The last update time."}
    expose :discarded_at, format_with: :iso_8601, documentation: {type: "DateTime", desc: "The discard time."}
  end
end
