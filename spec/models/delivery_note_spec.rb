# frozen_string_literal: true

RSpec.describe DeliveryNote do
  let(:trip) do
    truck = build_truck_with_tank(plate: "DN-1")
    route = Route.create!(origin: "Conakry", destination: "Labe", rate: 250)
    Trip.create!(truck: truck, route: route, actual_start_at: Time.zone.local(2026, 5, 12))
  end
  let(:note) do
    described_class.new(trip: trip, number: "DN-202605-001",
                        gasoline_quantity: 1_500, diesel_quantity: 0,
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
                                    gasoline_quantity: 500)
    duplicate.validate
    expect(duplicate.errors[:number]).to be_present
  end

  it "rejects a second delivery note for the same trip" do
    note.save!
    duplicate = described_class.new(trip: trip, number: "DN-202605-002",
                                    gasoline_quantity: 500)
    duplicate.validate
    expect(duplicate.errors[:trip_id]).to be_present
  end

  it "requires a non-zero gasoline or diesel quantity" do
    note.gasoline_quantity = 0
    note.diesel_quantity   = 0
    note.validate
    expect(note.errors[:base]).to be_present
  end

  it "rejects negative quantities" do
    note.gasoline_quantity = -1
    note.validate
    expect(note.errors[:gasoline_quantity]).to be_present
  end

  describe "tank-capacity validation (on :trip_creation)" do
    let(:trip) do
      truck = build_truck_with_tank(plate: "DN-CAP", capacity: 1_500)
      route = Route.create!(origin: "Conakry", destination: "Labe", rate: 250)
      Trip.create!(truck: truck, route: route)
    end
    let(:note) do
      described_class.new(trip: trip, number: "DN-CAP-1",
                          gasoline_quantity: gasoline, diesel_quantity: diesel)
    end

    context "when the load equals the tank capacity" do
      let(:gasoline) { 1_000 }
      let(:diesel)   { 500 }

      it "is valid in the :trip_creation context" do
        expect(note.valid?(:trip_creation)).to be true
      end
    end

    context "when the load is below the tank capacity" do
      let(:gasoline) { 1_000 }
      let(:diesel)   { 100 }

      it "adds a descriptive 'less than' error" do
        note.valid?(:trip_creation)
        expect(note.errors[:base].join).to include('is less than the tank capacity (1500 L)')
      end
    end

    context "when the load exceeds the tank capacity" do
      let(:gasoline) { 1_000 }
      let(:diesel)   { 800 }

      it "adds a descriptive 'exceeds' error" do
        note.valid?(:trip_creation)
        expect(note.errors[:base].join).to include('exceeds the tank capacity (1500 L)')
      end
    end

    context "when validating in the default context" do
      let(:gasoline) { 1_000 }
      let(:diesel)   { 100 }

      it "does not enforce the tank capacity" do
        expect(note.valid?).to be true
      end
    end
  end

  describe "#product" do
    it "is :gasoline when only gasoline is loaded" do
      expect(note.product).to eq(:gasoline)
    end

    it "is :diesel when only diesel is loaded" do
      note.gasoline_quantity = 0
      note.diesel_quantity   = 800
      expect(note.product).to eq(:diesel)
    end

    it "is :both when gasoline and diesel are loaded" do
      note.diesel_quantity = 600
      expect(note.product).to eq(:both)
    end
  end

  it "sums total_liters across gasoline and diesel" do
    note.diesel_quantity = 600
    expect(note.total_liters).to eq(2_100)
  end
end
