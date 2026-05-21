class DeliveryNote < ApplicationRecord
  include Discardable
  audited

  belongs_to :trip
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :number, presence: true, uniqueness: { case_sensitive: false }
  validates :trip_id, uniqueness: true
  validates :quantity_gasoline_liters, :quantity_diesel_liters,
            numericality: { greater_than_or_equal_to: 0 }
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
