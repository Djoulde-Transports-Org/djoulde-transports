# frozen_string_literal: true

RSpec.describe API::V1::Entities::Trip do
  let(:truck) { build_truck_with_tank(plate: "GN-ENTITY-#{SecureRandom.hex(2)}") }
  let(:route) { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }
  let(:trip)  { Trip.create!(truck: truck, route: route) }
  let(:payload) { JSON.parse(described_class.represent(trip).to_json) }

  it "exposes id" do
    expect(payload["id"]).to eq(trip.id)
  end

  it "exposes status as a string" do
    expect(payload["status"]).to eq("scheduled")
  end

  it "renders scheduled_start_at as an ISO 8601 timestamp when present" do
    trip.update!(scheduled_start_at: Time.zone.parse("2026-06-01 08:00:00"))
    expect(payload["scheduled_start_at"]).to match(/\d{4}-\d{2}-\d{2}T/)
  end

  it "exposes distance_km as a float" do
    trip.update!(distance_km: 350)
    expect(payload["distance_km"]).to eq(350.0)
  end

  describe "nested truck" do
    it "exposes truck.id" do
      expect(payload.dig("truck", "id")).to eq(truck.id)
    end

    it "exposes truck.plate_number" do
      expect(payload.dig("truck", "plate_number")).to eq(truck.plate_number)
    end

    it "exposes truck.status" do
      expect(payload.dig("truck", "status")).to eq("ready")
    end
  end

  describe "nested driver" do
    context "when the trip has no driver and the truck has none either" do
      it "exposes driver as nil" do
        expect(payload["driver"]).to be_nil
      end
    end

    context "when the trip has its own driver" do
      let(:trip_driver) { Employee.create!(first_name: "Ibra", last_name: "Bah") }
      let(:trip)        { Trip.create!(truck: truck, route: route, driver: trip_driver) }

      it "exposes the trip's driver" do
        expect(payload.dig("driver", "id")).to eq(trip_driver.id)
      end

      it "exposes the driver's first_name" do
        expect(payload.dig("driver", "first_name")).to eq("Ibra")
      end
    end

    context "when the trip has no driver but the truck has one assigned" do
      let(:truck_driver) { Employee.create!(first_name: "Mamadou", last_name: "Diallo") }

      before { truck.update!(driver: truck_driver) }

      it "falls back to the truck's driver" do
        expect(payload.dig("driver", "id")).to eq(truck_driver.id)
      end
    end
  end

  describe "nested route" do
    it "exposes route.id" do
      expect(payload.dig("route", "id")).to eq(route.id)
    end

    it "exposes route.origin" do
      expect(payload.dig("route", "origin")).to eq("Conakry")
    end

    it "exposes route.destination" do
      expect(payload.dig("route", "destination")).to eq("Labe")
    end
  end

  describe "nested billing_statement" do
    context "when no billing statement exists" do
      it "exposes billing_statement as nil" do
        expect(payload["billing_statement"]).to be_nil
      end
    end

    context "when a billing statement is linked via a line item" do
      let(:statement) do
        BillingStatement.create!(number: "BS-001", month: Date.new(2026, 6, 1),
                                 starts_on: Date.new(2026, 6, 1), ends_on: Date.new(2026, 6, 30))
      end

      before do
        BillingLineItem.create!(
          billing_statement: statement, trip: trip,
          delivery_note_number: "DN-001", started_on: Date.new(2026, 6, 10),
          origin: "Conakry", destination: "Labe",
          gasoline_quantity: 0, diesel_quantity: 5_000,
          rate: 1500, amount: 7_500_000, tva: 900_000
        )
      end

      it "exposes billing_statement.id" do
        expect(payload.dig("billing_statement", "id")).to eq(statement.id)
      end

      it "exposes billing_statement.number" do
        expect(payload.dig("billing_statement", "number")).to eq("BS-001")
      end
    end
  end

  describe "nested delivery_note" do
    context "when no delivery note exists" do
      it "exposes delivery_note as nil" do
        expect(payload["delivery_note"]).to be_nil
      end
    end

    context "when a delivery note exists" do
      before do
        DeliveryNote.create!(trip: trip, number: "DN-001",
                             gasoline_quantity: 10, diesel_quantity: 5)
      end

      it "exposes the delivery note number" do
        expect(payload.dig("delivery_note", "number")).to eq("DN-001")
      end

      it "exposes gasoline_quantity" do
        expect(payload.dig("delivery_note", "gasoline_quantity")).to eq(10)
      end

      it "exposes total_quantity as gasoline and diesel combined" do
        expect(payload.dig("delivery_note", "total_quantity")).to eq(15)
      end

      it "exposes diesel_quantity" do
        expect(payload.dig("delivery_note", "diesel_quantity")).to eq(5)
      end
    end
  end
end
