# == Schema Information
#
# Table name: billing_statements
# Database name: primary
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  due_on          :date
#  ends_on         :date             not null
#  grand_total     :integer          default(0), not null
#  issued_on       :date
#  month           :date             not null
#  number          :string(255)      not null
#  starts_on       :date             not null
#  status          :integer          default("draft"), not null
#  total_amount    :integer          default(0), not null
#  total_tva       :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discarded_by_id :bigint
#
# Indexes
#
#  index_billing_statements_on_discarded_at     (discarded_at)
#  index_billing_statements_on_discarded_by_id  (discarded_by_id)
#  index_billing_statements_on_month            (month) UNIQUE
#  index_billing_statements_on_number           (number) UNIQUE
#  index_billing_statements_on_status           (status)
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#
class BillingStatement < ApplicationRecord
  include Discardable
  audited
  has_associated_audits

  ISSUE_WINDOW_DAYS = 9 # the bill is issued between day 1 and day 10 of `month + 1`

  enum :status, { draft: 0, issued: 1, paid: 2, void: 3 }, default: :draft

  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :billing_line_items, dependent: :restrict_with_error
  has_many :documents, as: :documentable, dependent: :restrict_with_error

  validates :number, presence: true, uniqueness: { case_sensitive: false }
  validates :month, presence: true, uniqueness: true
  validates :total_amount, :total_tva, :grand_total,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate  :month_is_first_of_month
  validate  :issued_on_in_window

  before_validation :derive_period_dates

  scope :for_month, ->(date) { where(month: date.to_date.beginning_of_month) }
  scope :due_for_issue, ->(today = Date.current) {
    draft.where(month: ..today.to_date.prev_month.beginning_of_month)
  }

  def issue_window
    return unless month

    first = month.next_month
    first..(first + ISSUE_WINDOW_DAYS.days)
  end

  def recalculate_total!
    amount = billing_line_items.kept.sum(:amount)
    tva    = billing_line_items.kept.sum(:tva)
    update!(total_amount: amount, total_tva: tva, grand_total: amount + tva)
  end

  private

  def derive_period_dates
    return unless month

    self.starts_on ||= month.beginning_of_month
    self.ends_on   ||= month.end_of_month
  end

  def month_is_first_of_month
    return if month.blank?
    return if month == month.beginning_of_month

    errors.add(:month, "must be the first day of the month")
  end

  def issued_on_in_window
    return if issued_on.blank? || month.blank?
    return if issue_window.cover?(issued_on)

    errors.add(:issued_on, "must fall between #{issue_window.first} and #{issue_window.last}")
  end
end
