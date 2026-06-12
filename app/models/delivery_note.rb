# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_notes
# Database name: primary
#
#  id                :bigint           not null, primary key
#  delivered_on      :date
#  diesel_quantity   :integer          default(0), not null
#  discarded_at      :datetime
#  gasoline_quantity :integer          default(0), not null
#  missing_quantity  :integer          default(0), not null
#  number            :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  discarded_by_id   :bigint
#  trip_id           :bigint           not null
#
# Indexes
#
#  index_delivery_notes_on_discarded_at     (discarded_at)
#  index_delivery_notes_on_discarded_by_id  (discarded_by_id)
#  index_delivery_notes_on_number           (number) UNIQUE
#  index_delivery_notes_on_trip_id          (trip_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (trip_id => trips.id)
#
class DeliveryNote < ApplicationRecord
  include Discardable
  audited

  belongs_to :trip
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :number, presence: true, uniqueness: {case_sensitive: false}
  validates :trip_id, uniqueness: true
  validates :gasoline_quantity, :diesel_quantity, :missing_quantity,
            numericality: {greater_than_or_equal_to: 0}
  validate  :at_least_one_product
  # Enforced only when a trip is created (context :trip_creation): the loading
  # document must account for a full tank, no more and no less.
  validate  :loaded_quantity_fills_tank, on: :trip_creation

  def product
    gas    = gasoline_quantity.to_d.positive?
    diesel = diesel_quantity.to_d.positive?
    return :both     if gas && diesel
    return :gasoline if gas

    :diesel if diesel
  end

  def total_liters
    gasoline_quantity + diesel_quantity
  end

  private

  def at_least_one_product
    return if gasoline_quantity.to_d.positive? || diesel_quantity.to_d.positive?

    errors.add(:base, "must have a non-zero quantity of gasoline or diesel")
  end

  def loaded_quantity_fills_tank
    capacity = trip&.tank&.capacity
    return if capacity.nil?
    return if total_liters == capacity

    comparison = total_liters < capacity ? "is less than" : "exceeds"
    errors.add(:base,
      "loaded quantity (#{total_liters} L) #{comparison} the tank capacity (#{capacity} L)")
  end
end
