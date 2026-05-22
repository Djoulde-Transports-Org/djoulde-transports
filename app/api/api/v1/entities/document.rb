# frozen_string_literal: true

module API::V1::Entities
  class Document < Base
    expose :id
    expose :documentable_type
    expose :documentable_id
    expose :doc_type
    expose :title
    expose :issued_on
    expose :expires_on
    expose :uploaded_by_id
    expose :file_attached do |document|
      document.file.attached?
    end
    expose :created_at,   format_with: :iso_8601
    expose :updated_at,   format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
