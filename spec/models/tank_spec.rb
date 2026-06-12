# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tank do
  let(:truck) { Truck.create!(plate_number: "HEAD-#{SecureRandom.hex(2)}") }
  let(:tank)  { described_class.new(truck: truck, plate_number: "TK-1", capacity: 30_000) }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "is valid with a truck, plate_number, and capacity" do
    expect(tank).to be_valid
  end

  it "requires plate_number" do
    tank.plate_number = nil
    tank.validate
    expect(tank.errors[:plate_number]).to be_present
  end

  it "requires capacity" do
    tank.capacity = nil
    tank.validate
    expect(tank.errors[:capacity]).to be_present
  end

  it "rejects a second tank on the same truck" do
    described_class.create!(truck: truck, plate_number: "TK-A", capacity: 25_000)
    duplicate = described_class.new(truck: truck, plate_number: "TK-B", capacity: 25_000)
    duplicate.validate
    expect(duplicate.errors[:truck_id]).to be_present
  end

  it "enforces case-insensitive plate_number uniqueness" do
    described_class.create!(truck: truck, plate_number: "TK-9", capacity: 25_000)
    other_truck = Truck.create!(plate_number: "HEAD-X")
    duplicate = described_class.new(truck: other_truck, plate_number: "tk-9", capacity: 25_000)
    duplicate.validate
    expect(duplicate.errors[:plate_number]).to be_present
  end

  it "defaults status to active" do
    tank.save!
    expect(tank.status).to eq("active")
  end

  it "does not hard-destroy on discard" do
    tank.save!
    tank.discard
    expect(described_class.find(tank.id)).to be_discarded
  end
end
