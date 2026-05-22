# frozen_string_literal: true

module API::V1::Entities
  class Trip < Base
    expose :id
    expose :truck_id
    expose :tank_id
    expose :route_id
    expose :driver_id
    expose :status
    expose :cargo_description
    expose :distance_km
    expose :scheduled_start_at, format_with: :iso_8601
    expose :scheduled_end_at,   format_with: :iso_8601
    expose :actual_start_at,    format_with: :iso_8601
    expose :actual_end_at,      format_with: :iso_8601
    expose :created_at,         format_with: :iso_8601
    expose :updated_at,         format_with: :iso_8601
    expose :discarded_at,       format_with: :iso_8601
  end
end
