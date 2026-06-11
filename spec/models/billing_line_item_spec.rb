# frozen_string_literal: true

RSpec.describe BillingLineItem do
  let(:statement) do
    BillingStatement.create!(number: "INV-202605", month: Date.new(2026, 5, 1))
  end
  let(:trip) do
    truck = build_truck_with_tank(plate: "LI-1")
    route = Route.create!(origin: "Conakry", destination: "Labe", rate: 250)
    Trip.create!(truck: truck, route: route, actual_start_at: Time.zone.local(2026, 5, 12))
  end
  let(:line_item) do
    described_class.new(billing_statement: statement, trip: trip,
                        started_on: Date.new(2026, 5, 12),
                        delivery_note_number: "DN-1",
                        origin: "Conakry", destination: "Labe",
                        gasoline_quantity: 1_000, diesel_quantity: 500,
                        rate: 250,
                        amount: 375_000,
                        tva: 67_500)
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited and associated with billing_statement" do
    expect(described_class.audited_options[:associated_with]).to eq(:billing_statement)
  end

  it "requires a trip" do
    line_item.trip = nil
    line_item.validate
    expect(line_item.errors[:trip]).to be_present
  end

  it "rejects a negative amount" do
    line_item.amount = -1
    line_item.validate
    expect(line_item.errors[:amount]).to be_present
  end

  it "rejects negative quantities" do
    line_item.gasoline_quantity = -1
    line_item.validate
    expect(line_item.errors[:gasoline_quantity]).to be_present
  end

  it "rejects two line items for the same trip on the same statement" do
    line_item.save!
    duplicate = line_item.dup.tap { |li| li.delivery_note_number = "DN-2" }
    duplicate.validate
    expect(duplicate.errors[:trip_id]).to be_present
  end

  describe "#product" do
    it "is :both when gasoline and diesel are loaded" do
      expect(line_item.product).to eq(:both)
    end

    it "is :gasoline when only gasoline is loaded" do
      line_item.diesel_quantity = 0
      expect(line_item.product).to eq(:gasoline)
    end

    it "is :diesel when only diesel is loaded" do
      line_item.gasoline_quantity = 0
      expect(line_item.product).to eq(:diesel)
    end
  end

  describe ".from_trip" do
    before do
      DeliveryNote.create!(trip: trip, number: "DN-202605-001",
                           gasoline_quantity: 1_000, diesel_quantity: 500,
                           delivered_on: Date.new(2026, 5, 12))
    end

    it "snapshots origin and destination from the route" do
      line = described_class.from_trip(trip.reload, billing_statement: statement)
      expect([ line.origin, line.destination ]).to eq([ "Conakry", "Labe" ])
    end

    it "computes amount as (qty_gas + qty_diesel) * rate" do
      line = described_class.from_trip(trip.reload, billing_statement: statement)
      expect(line.amount).to eq(375_000)
    end

    it "computes tva as amount * 0.18" do
      line = described_class.from_trip(trip.reload, billing_statement: statement)
      expect(line.tva).to eq(67_500)
    end

    it "snapshots the delivery note number" do
      line = described_class.from_trip(trip.reload, billing_statement: statement)
      expect(line.delivery_note_number).to eq("DN-202605-001")
    end

    it "raises when the trip has no delivery_note" do
      trip.delivery_note.destroy
      expect { described_class.from_trip(trip.reload, billing_statement: statement) }
        .to raise_error(ArgumentError, /no delivery_note/)
    end
  end

  it "does not hard-destroy on discard" do
    line_item.save!
    line_item.discard
    expect(described_class.find(line_item.id)).to be_discarded
  end
end
