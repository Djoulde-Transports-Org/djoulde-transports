# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trips::Update do
  let(:truck) { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip)  { Trip.create!(truck: truck, route: route) }
  let!(:note) do
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                         gasoline_quantity: 10, diesel_quantity: 0)
  end

  it "updates the trip" do
    described_class.call(trip, {status: "completed"})
    expect(trip.reload.status).to eq("completed")
  end

  it "records the missing quantity on the delivery note when given" do
    described_class.call(trip, {status: "completed"}, 4)
    expect(note.reload.missing_quantity).to eq(4)
  end

  it "leaves the missing quantity unchanged when omitted" do
    described_class.call(trip, {status: "completed"})
    expect(note.reload.missing_quantity).to eq(0)
  end
end
