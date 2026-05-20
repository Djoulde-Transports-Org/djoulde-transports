class BillingPeriod < ApplicationRecord
  include Discardable
  audited

  enum :status, { open: 0, closed: 1, billed: 2 }, default: :open

  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :billing_statements, dependent: :restrict_with_error

  validates :label, presence: true, uniqueness: { case_sensitive: false }
  validates :starts_on, :ends_on, presence: true
  validate  :ends_on_after_starts_on

  private

  def ends_on_after_starts_on
    return if starts_on.blank? || ends_on.blank?
    return if ends_on >= starts_on

    errors.add(:ends_on, "must be on or after starts_on")
  end
end
