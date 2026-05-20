class BillingLineItem < ApplicationRecord
  include Discardable
  audited associated_with: :billing_statement

  belongs_to :billing_statement
  belongs_to :trip,         optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :amount_cents,     numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
