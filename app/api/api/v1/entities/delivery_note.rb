# frozen_string_literal: true

module API::V1::Entities
  class DeliveryNote < Base
    expose :id
    expose :trip_id
    expose :number
    expose :delivered_on
    expose :quantity_gasoline_liters
    expose :quantity_diesel_liters
    expose :product do |dn|
      dn.product&.to_s
    end
    expose :created_at,   format_with: :iso_8601
    expose :updated_at,   format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
