class Trip < ApplicationRecord
  include Discardable
  audited

  enum :status, {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }, default: :scheduled

  belongs_to :truck
  belongs_to :route
  belongs_to :driver,       class_name: "User", optional: true
  belongs_to :discarded_by, class_name: "User", optional: true

  has_many :documents,          as: :documentable, dependent: :restrict_with_error
  has_many :billing_line_items, dependent: :restrict_with_error

  validates :distance_km, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :scheduled_window_ordered
  validate  :actual_window_ordered

  scope :started_in_month, ->(year, month) {
    start = Date.new(year, month, 1)
    where(actual_start_at: start.beginning_of_day...start.next_month.beginning_of_day)
  }

  def origin
    route&.origin
  end

  def destination
    route&.destination
  end

  private

  def scheduled_window_ordered
    return if scheduled_start_at.blank? || scheduled_end_at.blank?
    return if scheduled_end_at >= scheduled_start_at

    errors.add(:scheduled_end_at, "must be on or after scheduled_start_at")
  end

  def actual_window_ordered
    return if actual_start_at.blank? || actual_end_at.blank?
    return if actual_end_at >= actual_start_at

    errors.add(:actual_end_at, "must be on or after actual_start_at")
  end
end
