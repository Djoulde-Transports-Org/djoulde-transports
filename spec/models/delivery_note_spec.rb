# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryNote do
  let(:trip) do
    truck = build_truck_with_tank(plate: "DN-1")
    route = Route.create!(origin: "Conakry", destination: "Labe", rate: 250)
    Trip.create!(truck: truck, route: route, actual_start_at: Time.zone.local(2026, 5, 12))
  end
  let(:note) do
    described_class.new(trip: trip, number: "DN-202605-001",
                        quantity_gasoline_liters: 1_500, quantity_diesel_liters: 0,
                        delivered_on: Date.new(2026, 5, 12))
  end
  let(:another_trip) do
    Trip.create!(truck: build_truck_with_tank(plate: "DN-2"),
                 route: trip.route, actual_start_at: Time.zone.now)
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "is valid with a trip, number, and a positive quantity" do
    expect(note).to be_valid
  end

  it "requires a number" do
    note.number = nil
    note.validate
    expect(note.errors[:number]).to be_present
  end

  it "enforces case-insensitive uniqueness of number" do
    note.save!
    duplicate = described_class.new(trip: another_trip, number: "dn-202605-001",
                                    quantity_gasoline_liters: 500)
    duplicate.validate
    expect(duplicate.errors[:number]).to be_present
  end

  it "rejects a second delivery note for the same trip" do
    note.save!
    duplicate = described_class.new(trip: trip, number: "DN-202605-002",
                                    quantity_gasoline_liters: 500)
    duplicate.validate
    expect(duplicate.errors[:trip_id]).to be_present
  end

  it "requires a non-zero gasoline or diesel quantity" do
    note.quantity_gasoline_liters = 0
    note.quantity_diesel_liters   = 0
    note.validate
    expect(note.errors[:base]).to be_present
  end

  it "rejects negative quantities" do
    note.quantity_gasoline_liters = -1
    note.validate
    expect(note.errors[:quantity_gasoline_liters]).to be_present
  end

  describe "#product" do
    it "is :gasoline when only gasoline is loaded" do
      expect(note.product).to eq(:gasoline)
    end

    it "is :diesel when only diesel is loaded" do
      note.quantity_gasoline_liters = 0
      note.quantity_diesel_liters   = 800
      expect(note.product).to eq(:diesel)
    end

    it "is :both when gasoline and diesel are loaded" do
      note.quantity_diesel_liters = 600
      expect(note.product).to eq(:both)
    end
  end

  it "sums total_liters across gasoline and diesel" do
    note.quantity_diesel_liters = 600
    expect(note.total_liters).to eq(2_100)
  end
end
