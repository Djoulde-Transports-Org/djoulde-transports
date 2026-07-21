# frozen_string_literal: true

RSpec.describe API::V1::Entities::Truck do
  let(:truck) do
    Truck.create!(
      plate_number: "GN-#{SecureRandom.hex(3).upcase}",
      vin: "VIN#{SecureRandom.hex(8).upcase}",
      make: "Volvo",
      model: "FH",
      year: 2022,
      status: :ready
    )
  end

  # to_json goes through the full Grape serialization path, applying format_with
  # formatters on block-based exposures. as_json skips them for blocks.
  let(:payload) { JSON.parse(described_class.represent(truck).to_json) }

  it "exposes id" do
    expect(payload["id"]).to eq(truck.id)
  end

  it "exposes plate_number" do
    expect(payload["plate_number"]).to eq(truck.plate_number)
  end

  it "exposes vin" do
    expect(payload["vin"]).to eq(truck.vin)
  end

  it "exposes make" do
    expect(payload["make"]).to eq("Volvo")
  end

  it "exposes model" do
    expect(payload["model"]).to eq("FH")
  end

  it "exposes year" do
    expect(payload["year"]).to eq(2022)
  end

  it "exposes status as a string" do
    expect(payload["status"]).to eq("ready")
  end

  describe "driver" do
    context "when no driver is assigned" do
      it "exposes driver as nil" do
        expect(payload["driver"]).to be_nil
      end
    end

    context "when a driver is assigned" do
      let(:driver) { Employee.create!(first_name: "Mamadou", last_name: "Diallo", phone_number: "+224600000000") }
      let(:truck) do
        Truck.create!(
          plate_number: "GN-#{SecureRandom.hex(3).upcase}",
          vin: "VIN#{SecureRandom.hex(8).upcase}",
          make: "Volvo",
          model: "FH",
          year: 2022,
          status: :ready,
          driver: driver
        )
      end

      it "exposes driver.id" do
        expect(payload.dig("driver", "id")).to eq(driver.id)
      end

      it "exposes driver.first_name" do
        expect(payload.dig("driver", "first_name")).to eq("Mamadou")
      end

      it "exposes driver.last_name" do
        expect(payload.dig("driver", "last_name")).to eq("Diallo")
      end

      it "exposes driver.phone_number" do
        expect(payload.dig("driver", "phone_number")).to eq("+224600000000")
      end
    end
  end

  describe "tank" do
    context "when no tank is attached" do
      it "exposes tank as nil" do
        expect(payload["tank"]).to be_nil
      end
    end

    context "when a tank is attached" do
      before do
        Tank.create!(
          truck: truck,
          plate_number: "TK-#{SecureRandom.hex(3).upcase}",
          vin: "TK#{SecureRandom.hex(8).upcase}",
          make: "Trailer Co",
          model: "T500",
          year: 2021,
          capacity: 30_000
        )
      end

      it "exposes the tank with its capacity" do
        expect(payload.dig("tank", "capacity")).to eq(30_000)
      end
    end
  end

  describe "last_oil_change_on" do
    context "when no oil change maintenance exists" do
      it "returns nil" do
        expect(payload["last_oil_change_on"]).to be_nil
      end
    end

    context "when oil change maintenances exist" do
      before do
        Maintenance.create!(truck: truck, kind: :oil_change, performed_on: Date.new(2025, 1, 1))
        Maintenance.create!(truck: truck, kind: :oil_change, performed_on: Date.new(2025, 6, 15))
      end

      it "returns the most recent date as an ISO 8601 date" do
        expect(payload["last_oil_change_on"]).to eq("2025-06-15")
      end
    end

    context "when the oil change maintenance is discarded" do
      before do
        Maintenance.create!(truck: truck, kind: :oil_change, performed_on: Date.new(2025, 3, 1)).discard
      end

      it "returns nil" do
        expect(payload["last_oil_change_on"]).to be_nil
      end
    end

    context "when only non-oil-change maintenances exist" do
      before do
        Maintenance.create!(truck: truck, kind: :routine, performed_on: Date.new(2025, 5, 1))
      end

      it "returns nil" do
        expect(payload["last_oil_change_on"]).to be_nil
      end
    end
  end

  describe "document expiry fields" do
    let(:future_date) { Date.current + 120 }
    let(:past_date)   { Date.current - 5 }

    def create_doc(doc_type:, expires_on:)
      Document.create!(
        documentable: truck,
        doc_type: doc_type,
        number: "DOC-#{SecureRandom.hex(5)}",
        title: doc_type.to_s.titleize,
        issued_on: Date.current - 365,
        expires_on: expires_on
      )
    end

    context "when no documents exist" do
      it "returns nil for all expiry dates", :aggregate_failures do
        expect(payload["truck_insurance_expires_on"]).to be_nil
        expect(payload["cargo_insurance_expires_on"]).to be_nil
        expect(payload["technical_inspection_expires_on"]).to be_nil
        expect(payload["operating_permit_expires_on"]).to be_nil
        expect(payload["truck_registration_expires_on"]).to be_nil
      end

      it "returns nil for all days_remaining values", :aggregate_failures do
        expect(payload["truck_insurance_days_remaining"]).to be_nil
        expect(payload["cargo_insurance_days_remaining"]).to be_nil
        expect(payload["technical_inspection_days_remaining"]).to be_nil
        expect(payload["operating_permit_days_remaining"]).to be_nil
        expect(payload["truck_registration_days_remaining"]).to be_nil
      end
    end

    context "when a truck insurance document exists" do
      before { create_doc(doc_type: :truck_insurance, expires_on: future_date) }

      it "returns truck_insurance_expires_on as an ISO 8601 date" do
        expect(payload["truck_insurance_expires_on"]).to eq(future_date.iso8601)
      end

      it "returns a positive truck_insurance_days_remaining" do
        expect(payload["truck_insurance_days_remaining"]).to be > 0
      end
    end

    context "when a technical inspection document is expired" do
      before { create_doc(doc_type: :technical_inspection, expires_on: past_date) }

      it "returns technical_inspection_expires_on" do
        expect(payload["technical_inspection_expires_on"]).to eq(past_date.iso8601)
      end

      it "returns a negative technical_inspection_days_remaining" do
        expect(payload["technical_inspection_days_remaining"]).to be < 0
      end
    end

    context "when a truck registration document exists" do
      before { create_doc(doc_type: :truck_registration, expires_on: future_date) }

      it "returns truck_registration_expires_on as an ISO 8601 date" do
        expect(payload["truck_registration_expires_on"]).to eq(future_date.iso8601)
      end

      it "returns a positive truck_registration_days_remaining" do
        expect(payload["truck_registration_days_remaining"]).to be > 0
      end
    end

    context "when a document is discarded" do
      before { create_doc(doc_type: :truck_insurance, expires_on: future_date).discard }

      it "excludes the discarded document" do
        expect(payload["truck_insurance_expires_on"]).to be_nil
      end
    end

    context "when multiple documents of the same type exist" do
      let(:older_date) { Date.current + 30 }

      before do
        create_doc(doc_type: :truck_insurance, expires_on: older_date)
        create_doc(doc_type: :truck_insurance, expires_on: future_date)
      end

      it "returns the latest expiry date" do
        expect(payload["truck_insurance_expires_on"]).to eq(future_date.iso8601)
      end
    end
  end

  describe "stats" do
    it "returns trips_count as 0 when the truck has no trips" do
      expect(payload["trips_count"]).to eq(0)
    end

    it "returns total_km as 0.0 when the truck has no trips" do
      expect(payload["total_km"]).to eq(0.0)
    end

    it "returns total_liters_delivered as 0 when there are no delivery notes" do
      expect(payload["total_liters_delivered"]).to eq(0)
    end
  end
end
