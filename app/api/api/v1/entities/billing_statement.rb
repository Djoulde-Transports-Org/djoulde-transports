# frozen_string_literal: true

module API::V1::Entities
  class BillingStatement < Base
    expose :id
    expose :number
    expose :status
    expose :month
    expose :starts_on
    expose :ends_on
    expose :issued_on
    expose :due_on
    expose :total_amount
    expose :total_tva
    expose :grand_total
    expose :created_at,   format_with: :iso_8601
    expose :updated_at,   format_with: :iso_8601
    expose :discarded_at, format_with: :iso_8601
  end
end
