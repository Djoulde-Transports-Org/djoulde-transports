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

  describe "the returned result" do
    let(:result) { described_class.call(truck) }

    it "is a Trucks::Discard::Result" do
      expect(result).to be_a(Trucks::Discard::Result)
    end

    it "is successful" do
      expect(result.success).to be true
    end

    it "carries a message that names the truck id" do
      expect(result.message).to eq("Truck #{truck.id} has been successfully discarded.")
    end
  end
end
