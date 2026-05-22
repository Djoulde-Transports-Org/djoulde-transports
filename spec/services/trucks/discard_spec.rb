# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucks::Discard do
  let(:truck) { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }

  it "discards the truck" do
    described_class.call(truck)
    expect(truck.reload.discarded?).to be true
  end

  it "cascades discard to kept trips" do
    trip = Trip.create!(truck: truck, route: route)
    described_class.call(truck)
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
