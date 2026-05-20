class BillingStatement < ApplicationRecord
  include Discardable
  audited
  has_associated_audits

  enum :status, { draft: 0, issued: 1, paid: 2, void: 3 }, default: :draft

  belongs_to :billing_period
  belongs_to :customer,     class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :billing_line_items, dependent: :restrict_with_error
  has_many :documents, as: :documentable, dependent: :restrict_with_error

  validates :number, presence: true, uniqueness: { case_sensitive: false }
  validates :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
