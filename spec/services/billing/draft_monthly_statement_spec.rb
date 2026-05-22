# frozen_string_literal: true

require "rails_helper"

RSpec.describe Billing::DraftMonthlyStatement do
  let(:month) { Date.new(2026, 3, 1) }
  let(:truck) { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }

  def trip_with_note(start_at:, gasoline: 10, diesel: 0)
    trip = Trip.create!(truck: truck, route: route, actual_start_at: start_at)
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(3)}",
                         quantity_gasoline_liters: gasoline, quantity_diesel_liters: diesel)
    trip
  end

  it "creates a draft statement for the month" do
    described_class.call(month: month)
    expect(BillingStatement.for_month(month).first).to be_present
  end

  it "materializes one line item per billable trip" do
    trip_with_note(start_at: month + 5.days)
    trip_with_note(start_at: month + 10.days)
    statement = described_class.call(month: month)
    expect(statement.billing_line_items.count).to eq(2)
  end

  it "is idempotent: re-running returns the same statement without dup line items" do
    trip_with_note(start_at: month + 5.days)
    first  = described_class.call(month: month)
    second = described_class.call(month: month)
    expect(second.id).to eq(first.id)
  end

  it "matches BillingLineItem.from_trip in totals" do
    trip = trip_with_note(start_at: month + 5.days, gasoline: 10, diesel: 0)
    statement = described_class.call(month: month)
    expected_amount = (trip.delivery_note.total_liters * route.rate).round.to_i
    expect(statement.total_amount).to eq(expected_amount)
  end

  it "ignores trips from other months" do
    trip_with_note(start_at: month - 1.day)
    statement = described_class.call(month: month)
    expect(statement.billing_line_items.count).to eq(0)
  end

  it "ignores discarded trips" do
    trip = trip_with_note(start_at: month + 5.days)
    trip.discard
    statement = described_class.call(month: month)
    expect(statement.billing_line_items.count).to eq(0)
  end
end
