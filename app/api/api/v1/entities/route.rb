# frozen_string_literal: true

module API::V1::Entities
  class Route < Base
    expose :id
    expose :origin
    expose :destination
    expose :rate
    expose :created_at, format_with: :iso_8601
    expose :updated_at, format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
