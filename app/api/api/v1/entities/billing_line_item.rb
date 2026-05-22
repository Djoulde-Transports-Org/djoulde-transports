# frozen_string_literal: true

module API::V1::Entities
  class BillingLineItem < Base
    expose :id
    expose :billing_statement_id
    expose :trip_id
    expose :delivery_note_number
    expose :started_on
    expose :origin
    expose :destination
    expose :quantity_gasoline_liters
    expose :quantity_diesel_liters
    expose :rate
    expose :amount
    expose :tva
    expose :created_at,   format_with: :iso_8601
    expose :updated_at,   format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
