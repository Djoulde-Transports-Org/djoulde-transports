# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucks::Discard do
  let(:truck)         { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:truck_w_tank)  { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route)         { Route.create!(origin: "A", destination: "B", rate: 1000) }

  it "discards a truck with no tank" do
    described_class.call(truck)
    expect(truck.reload.discarded?).to be true
  end

  it "raises HasDependents when the truck still has a kept tank" do
    expect { described_class.call(truck_w_tank) }
      .to raise_error(ApplicationService::HasDependents)
  end

  it "cascades discard to kept trips (after the tank is retired)" do
    trip = Trip.create!(truck: truck_w_tank, route: route)
    truck_w_tank.tank.discard
    described_class.call(truck_w_tank)
    expect(trip.reload.discarded?).to be true
  end

  it "cascades discard to kept maintenances" do
    maintenance = Maintenance.create!(truck: truck, performed_on: Time.zone.today)
    described_class.call(truck)
    expect(maintenance.reload.discarded?).to be true
  end

  it "cascades discard to kept documents" do
    document = Document.create!(documentable: truck, title: "Insurance")
    described_class.call(truck)
    expect(document.reload.discarded?).to be true
  end
end
