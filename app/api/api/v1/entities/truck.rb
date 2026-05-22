# frozen_string_literal: true

module API::V1::Entities
  class Truck < Base
    expose :id
    expose :plate_number
    expose :vin
    expose :make
    expose :model
    expose :year
    expose :status
    expose :created_by_id
    expose :created_at, format_with: :iso_8601
    expose :updated_at, format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
