# frozen_string_literal: true

require "rails_helper"

RSpec.describe Maintenances::Update do
  let(:truck)       { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance) { Maintenance.create!(truck: truck, performed_on: Time.zone.today, cost: 100) }

  it "updates the maintenance fields" do
    described_class.call(maintenance, {cost: 250})
    expect(maintenance.reload.cost).to eq(250)
  end

  it "leaves parts untouched when parts is omitted" do
    maintenance.parts.create!(name: "filter", price: 1100)
    described_class.call(maintenance, {cost: 250})
    expect(maintenance.parts.kept.pluck(:name)).to eq([ "filter" ])
  end

  context "when parts are supplied" do
    before { maintenance.parts.create!(name: "old part", price: 500) }

    it "replaces the existing parts" do
      described_class.call(maintenance, {}, [ {name: "filter", price: 1100} ])
      expect(maintenance.parts.kept.pluck(:name, :price)).to contain_exactly([ "filter", 1100 ])
    end

    it "discards the previous parts" do
      old = maintenance.parts.first
      described_class.call(maintenance, {}, [ {name: "filter", price: 1100} ])
      expect(old.reload.discarded?).to be true
    end

    it "clears parts when given an empty array" do
      described_class.call(maintenance, {}, [])
      expect(maintenance.parts.kept).to be_empty
    end

    it "recomputes the cost from the new part prices" do
      described_class.call(maintenance, {}, [ {name: "filter", price: 1100}, {name: "belt", price: 800} ])
      expect(maintenance.reload.cost).to eq(1900)
    end

    it "sets the cost to zero when parts are cleared" do
      described_class.call(maintenance, {}, [])
      expect(maintenance.reload.cost).to eq(0)
    end
  end

  context "when completing the maintenance" do
    before { truck.in_maintenance! }

    it "marks the maintenance completed" do
      described_class.call(maintenance, {state: "completed"})
      expect(maintenance.reload).to be_completed
    end

    it "stamps the actual duration from the elapsed time" do
      travel_to(3.hours.ago) { maintenance } # open the maintenance 3 hours ago
      described_class.call(maintenance, {state: "completed"})
      expect(maintenance.reload.actual_duration).to eq(3.0)
    end

    it "returns the truck to the ready status" do
      described_class.call(maintenance, {state: "completed"})
      expect(truck.reload).to be_ready
    end

    it "does not re-stamp an already completed maintenance" do
      travel_to(3.hours.ago) { maintenance } # open the maintenance 3 hours ago
      described_class.call(maintenance, {state: "completed"})
      stamped = maintenance.reload.actual_duration

      # A later edit that does not change the state must leave the duration as
      # stamped, even though more time has since elapsed.
      travel_to(5.hours.from_now) do
        described_class.call(maintenance, {description: "follow-up note"})
      end
      expect(maintenance.reload.actual_duration).to eq(stamped)
    end
  end
end
