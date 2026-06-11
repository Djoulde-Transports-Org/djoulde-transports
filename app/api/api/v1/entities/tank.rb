# frozen_string_literal: true

module API::V1::Entities
  class Tank < Base
    expose :id
    expose :truck_id
    expose :plate_number
    expose :vin
    expose :make
    expose :model
    expose :year
    expose :capacity_liters
    expose :status
    expose :created_at,   format_with: :iso_8601
    expose :updated_at,   format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
