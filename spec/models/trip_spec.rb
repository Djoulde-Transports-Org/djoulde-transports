require "rails_helper"

RSpec.describe Trip do
  let(:truck) { Truck.create!(plate_number: "PLATE-1") }
  let(:trip) do
    described_class.new(truck: truck, origin: "Conakry", destination: "Labe")
  end

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

  it "requires origin" do
    trip.origin = nil
    trip.validate
    expect(trip.errors[:origin]).to be_present
  end

  it "requires destination" do
    trip.destination = nil
    trip.validate
    expect(trip.errors[:destination]).to be_present
  end

  it "defaults status to scheduled" do
    trip.save!
    expect(trip.status).to eq("scheduled")
  end

  it "exposes the four status states" do
    expect(described_class.statuses.keys)
      .to contain_exactly("scheduled", "in_progress", "completed", "cancelled")
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

  it "does not hard-destroy on discard" do
    trip.save!
    trip.discard
    expect(described_class.find(trip.id)).to be_discarded
  end
end
