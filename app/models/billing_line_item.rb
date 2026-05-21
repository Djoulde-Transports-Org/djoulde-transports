class BillingLineItem < ApplicationRecord
  include Discardable
  audited associated_with: :billing_statement

  # Statutory VAT for Guinea (18%). Per-line `tva` is snapshotted at issue
  # time, so historical bills are unaffected if the rate ever changes.
  TVA_RATE = BigDecimal("0.18")

  belongs_to :billing_statement
  belongs_to :trip
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :trip_id, uniqueness: { scope: :billing_statement_id }
  validates :amount, :tva, :rate,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity_gasoline_liters, :quantity_diesel_liters,
            numericality: { greater_than_or_equal_to: 0 }

  # Build (but do not save) a line item snapshotted from a trip + its route +
  # its delivery note. The billing job (ticket 11) is the intended caller.
  def self.from_trip(trip, billing_statement:)
    note  = trip.delivery_note or raise ArgumentError, "trip #{trip.id} has no delivery_note"
    route = trip.route
    qty   = note.quantity_gasoline_liters + note.quantity_diesel_liters
    amount = (qty * route.rate).round.to_i

    new(
      billing_statement: billing_statement,
      trip: trip,
      started_on: trip.actual_start_at&.to_date,
      delivery_note_number: note.number,
      origin: route.origin,
      destination: route.destination,
      quantity_gasoline_liters: note.quantity_gasoline_liters,
      quantity_diesel_liters:   note.quantity_diesel_liters,
      rate: route.rate,
      amount: amount,
      tva: (BigDecimal(amount) * TVA_RATE).round.to_i
    )
  end

  def total_liters
    quantity_gasoline_liters + quantity_diesel_liters
  end

  def product
    gas    = quantity_gasoline_liters.to_d.positive?
    diesel = quantity_diesel_liters.to_d.positive?
    return :both     if gas && diesel
    return :gasoline if gas

    :diesel if diesel
  end
end
