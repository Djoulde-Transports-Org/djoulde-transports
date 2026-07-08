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

      it "exposes diesel_quantity" do
        expect(payload.dig("delivery_note", "diesel_quantity")).to eq(5)
      end
    end
  end
end
