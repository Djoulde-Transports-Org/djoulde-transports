# frozen_string_literal: true

# == Schema Information
#
# Table name: billing_line_items
# Database name: primary
#
#  id                   :bigint           not null, primary key
#  amount               :integer          not null
#  delivery_note_number :string(255)
#  destination          :string(255)
#  diesel_quantity      :integer          default(0), not null
#  discarded_at         :datetime
#  gasoline_quantity    :integer          default(0), not null
#  origin               :string(255)
#  rate                 :decimal(12, 2)   default(0.0), not null
#  started_on           :date
#  tva                  :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  billing_statement_id :bigint           not null
#  discarded_by_id      :bigint
#  trip_id              :bigint           not null
#
# Indexes
#
#  index_billing_line_items_on_billing_statement_id  (billing_statement_id)
#  index_billing_line_items_on_delivery_note_number  (delivery_note_number)
#  index_billing_line_items_on_discarded_at          (discarded_at)
#  index_billing_line_items_on_discarded_by_id       (discarded_by_id)
#  index_billing_line_items_on_statement_and_trip    (billing_statement_id,trip_id) UNIQUE
#  index_billing_line_items_on_trip_id               (trip_id)
#
# Foreign Keys
#
#  fk_rails_...  (billing_statement_id => billing_statements.id)
#  fk_rails_...  (discarded_by_id => users.id)
#  fk_rails_...  (trip_id => trips.id)
#
class BillingLineItem < ApplicationRecord
  include Discardable
  audited associated_with: :billing_statement

  # Statutory VAT for Guinea (18%). Per-line `tva` is snapshotted at issue
  # time, so historical bills are unaffected if the rate ever changes.
  TVA_RATE = BigDecimal("0.18")

  belongs_to :billing_statement
  belongs_to :trip
  belongs_to :discarded_by, class_name: "User", optional: true

  validates :trip_id, uniqueness: {scope: :billing_statement_id}
  validates :amount, :tva,
            numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :rate, numericality: {greater_than_or_equal_to: 0}
  validates :gasoline_quantity, :diesel_quantity,
            numericality: {greater_than_or_equal_to: 0}

  # Build (but do not save) a line item snapshotted from a trip + its route +
  # its delivery note. The billing job (ticket 11) is the intended caller.
  def self.from_trip(trip, billing_statement:)
    note  = trip.delivery_note or raise ArgumentError, "trip #{trip.id} has no delivery_note"
    route = trip.route
    qty   = note.gasoline_quantity + note.diesel_quantity
    amount = (qty * route.rate).round.to_i

    new(
      billing_statement: billing_statement,
      trip: trip,
      started_on: trip.actual_start_at&.to_date,
      delivery_note_number: note.number,
      origin: route.origin,
      destination: route.destination,
      gasoline_quantity: note.gasoline_quantity,
      diesel_quantity:   note.diesel_quantity,
      rate: route.rate,
      amount: amount,
      tva: (BigDecimal(amount) * TVA_RATE).round.to_i
    )
  end

  def total_liters
    gasoline_quantity + diesel_quantity
  end

  def product
    gas    = gasoline_quantity.to_d.positive?
    diesel = diesel_quantity.to_d.positive?
    return :both     if gas && diesel
    return :gasoline if gas

    :diesel if diesel
  end
end
