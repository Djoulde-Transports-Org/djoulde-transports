# frozen_string_literal: true

module API::V1::Entities
  class Maintenance < Base
    expose :id
    expose :truck_id
    expose :performed_by_id
    expose :kind
    expose :performed_on
    expose :cost
    expose :odometer_km
    expose :description
    expose :created_at,   format_with: :iso_8601
    expose :updated_at,   format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
