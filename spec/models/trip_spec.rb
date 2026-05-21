# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trip do
  let(:truck) { Truck.create!(plate_number: "PLATE-1") }
  let(:route) { Route.create!(origin: "Conakry", destination: "Labe", rate: 250) }
  let(:trip)  { described_class.new(truck: truck, route: route) }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "requires a truck" do
    trip.truck = nil
    trip.validate
    expect(trip.errors[:truck]).to be_present
  end

  it "requires a route" do
    trip.route = nil
    trip.validate
    expect(trip.errors[:route]).to be_present
  end

  it "defaults status to scheduled" do
    trip.save!
    expect(trip.status).to eq("scheduled")
  end

  it "exposes the four status states" do
    expect(described_class.statuses.keys)
      .to contain_exactly("scheduled", "in_progress", "completed", "cancelled")
  end

  it "delegates origin to the route" do
    expect(trip.origin).to eq("Conakry")
  end

  it "delegates destination to the route" do
    expect(trip.destination).to eq("Labe")
  end

  it "rejects a scheduled_end_at earlier than scheduled_start_at" do
    trip.scheduled_start_at = Time.zone.now
    trip.scheduled_end_at   = 1.hour.ago
    trip.validate
    expect(trip.errors[:scheduled_end_at]).to be_present
  end

  it "rejects an actual_end_at earlier than actual_start_at" do
    trip.actual_start_at = Time.zone.now
    trip.actual_end_at   = 1.hour.ago
    trip.validate
    expect(trip.errors[:actual_end_at]).to be_present
  end

  it "associates has_many :documents as :documentable" do
    reflection = described_class.reflect_on_association(:documents)
    expect(reflection.options[:as]).to eq(:documentable)
  end

  it "associates has_one :delivery_note" do
    expect(described_class.reflect_on_association(:delivery_note).macro).to eq(:has_one)
  end

  describe ".started_in_month" do
    let!(:may_trip) do
      described_class.create!(truck: truck, route: route, actual_start_at: Time.zone.local(2026, 5, 15, 8))
    end
    let!(:june_trip) do
      described_class.create!(truck: truck, route: route, actual_start_at: Time.zone.local(2026, 6, 1, 0))
    end

    it "returns trips whose actual_start_at falls in the month" do
      expect(described_class.started_in_month(2026, 5)).to contain_exactly(may_trip)
    end

    it "excludes trips that start in a different month" do
      expect(described_class.started_in_month(2026, 5)).not_to include(june_trip)
    end
  end

  it "does not hard-destroy on discard" do
    trip.save!
    trip.discard
    expect(described_class.find(trip.id)).to be_discarded
  end
end
