# frozen_string_literal: true

# == Schema Information
#
# Table name: trips
# Database name: primary
#
#  id                 :bigint           not null, primary key
#  actual_end_at      :datetime
#  actual_start_at    :datetime
#  cargo_description  :text(65535)
#  discarded_at       :datetime
#  distance_km        :decimal(10, 2)
#  scheduled_end_at   :datetime
#  scheduled_start_at :datetime
#  status             :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_by_id    :bigint
#  driver_id          :bigint
#  route_id           :bigint           not null
#  tank_id            :bigint           not null
#  truck_id           :bigint           not null
#
# Indexes
#
#  index_trips_on_discarded_at                             (discarded_at)
#  index_trips_on_discarded_by_id                          (discarded_by_id)
#  index_trips_on_driver_id                                (driver_id)
#  index_trips_on_driver_id_and_scheduled_start_at_and_id  (driver_id,scheduled_start_at,id)
#  index_trips_on_route_id                                 (route_id)
#  index_trips_on_status                                   (status)
#  index_trips_on_status_and_scheduled_start_at_and_id     (status,scheduled_start_at,id)
#  index_trips_on_tank_id                                  (tank_id)
#  index_trips_on_truck_id                                 (truck_id)
#  index_trips_on_truck_id_and_scheduled_start_at_and_id   (truck_id,scheduled_start_at,id)
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (driver_id => employees.id)
#  fk_rails_...  (route_id => routes.id)
#  fk_rails_...  (tank_id => tanks.id)
#  fk_rails_...  (truck_id => trucks.id)
#
class Trip < ApplicationRecord
  include Discardable
  audited

  enum :status, {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3,
  }, default: :scheduled

  belongs_to :truck
  belongs_to :tank
  belongs_to :route
  belongs_to :driver,       class_name: "Employee", optional: true, inverse_of: :trips
  belongs_to :discarded_by, class_name: "User", optional: true

  has_one  :delivery_note,    dependent: :restrict_with_error
  has_many :documents,          as: :documentable, dependent: :restrict_with_error
  has_many :billing_line_items, dependent: :restrict_with_error

  before_validation :default_tank_from_truck,   on: :create
  before_validation :default_driver_from_truck, on: :create

  validates :distance_km, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
  validate  :scheduled_window_ordered
  validate  :actual_window_ordered
  validate  :tank_matches_truck

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

  def tank_matches_truck
    return if tank_id.blank? || truck_id.blank?
    return if tank.truck_id == truck_id

    errors.add(:tank_id, "is paired with a different truck")
  end

  def default_tank_from_truck
    return if tank_id.present? || truck.blank?

    self.tank = truck.tank
  end

  def default_driver_from_truck
    return if driver_id.present? || truck.blank?

    self.driver = truck.driver
  end
end
