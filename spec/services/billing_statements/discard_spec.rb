# frozen_string_literal: true

require "rails_helper"

RSpec.describe BillingStatements::Discard do
  let(:month)     { Time.zone.today.prev_month.beginning_of_month }
  let(:statement) { BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}") }

  it "discards an empty statement" do
    described_class.call(statement)
    expect(statement.reload.discarded?).to be true
  end

  it "raises HasDependents when kept line items exist" do
    truck = build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}")
    route = Route.create!(origin: "A", destination: "B", rate: 1000)
    trip  = Trip.create!(truck: truck, route: route, actual_start_at: month + 5.days)
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                         quantity_gasoline_liters: 5, quantity_diesel_liters: 0)
    BillingLineItem.from_trip(trip, billing_statement: statement).save!

    expect { described_class.call(statement) }
      .to raise_error(ApplicationService::HasDependents)
  end
end
