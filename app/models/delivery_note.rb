# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_notes
# Database name: primary
#
#  id                       :bigint           not null, primary key
#  delivered_on             :date
#  discarded_at             :datetime
#  number                   :string(255)      not null
#  quantity_diesel_liters   :decimal(12, 2)   default(0.0), not null
#  quantity_gasoline_liters :decimal(12, 2)   default(0.0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  discarded_by_id          :bigint
#  trip_id                  :bigint           not null
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
  validates :quantity_gasoline_liters, :quantity_diesel_liters,
            numericality: {greater_than_or_equal_to: 0}
  validate  :at_least_one_product

  def product
    gas    = quantity_gasoline_liters.to_d.positive?
    diesel = quantity_diesel_liters.to_d.positive?
    return :both     if gas && diesel
    return :gasoline if gas

    :diesel if diesel
  end

  def total_liters
    quantity_gasoline_liters + quantity_diesel_liters
  end

  private

  def at_least_one_product
    return if quantity_gasoline_liters.to_d.positive? || quantity_diesel_liters.to_d.positive?

    errors.add(:base, "must have a non-zero quantity of gasoline or diesel")
  end
end
