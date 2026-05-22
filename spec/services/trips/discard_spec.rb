# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trips::Discard do
  let(:truck) { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip)  { Trip.create!(truck: truck, route: route) }

  it "discards the trip" do
    described_class.call(trip)
    expect(trip.reload.discarded?).to be true
  end

  it "cascades to the delivery note" do
    note = DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                                quantity_gasoline_liters: 5, quantity_diesel_liters: 0)
    described_class.call(trip)
    expect(note.reload.discarded?).to be true
  end

  it "raises HasDependents when the trip is already billed" do
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                         quantity_gasoline_liters: 5, quantity_diesel_liters: 0)
    statement = BillingStatement.create!(month: Time.zone.today.beginning_of_month, number: "X")
    BillingLineItem.from_trip(trip, billing_statement: statement).save!

    expect { described_class.call(trip) }
      .to raise_error(ApplicationService::HasDependents)
  end
end
