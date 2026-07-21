# frozen_string_literal: true

RSpec.describe API::V1::Entities::Tank do
  let(:truck) { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:tank) do
    Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(2)}", make: "Volvo",
                 model: "Cistern", year: 2021, capacity: 30_000)
  end
  let(:payload) { JSON.parse(described_class.represent(tank).to_json) }

  it "exposes id" do
    expect(payload["id"]).to eq(tank.id)
  end

  it "exposes truck_id" do
    expect(payload["truck_id"]).to eq(truck.id)
  end

  it "exposes plate_number" do
    expect(payload["plate_number"]).to eq(tank.plate_number)
  end

  it "exposes make" do
    expect(payload["make"]).to eq("Volvo")
  end

  it "exposes model" do
    expect(payload["model"]).to eq("Cistern")
  end

  it "exposes year" do
    expect(payload["year"]).to eq(2021)
  end

  it "exposes capacity" do
    expect(payload["capacity"]).to eq(30_000)
  end

  it "exposes status as a string" do
    expect(payload["status"]).to eq("active")
  end

  describe "conformity certificate expiry fields" do
    let(:future_date) { Date.current + 90 }

    def create_doc(expires_on:)
      Document.create!(
        documentable: tank,
        doc_type: :conformity_certificate,
        number: "DOC-#{SecureRandom.hex(5)}",
        title: "Certificat de baremage",
        issued_on: Date.current - 365,
        expires_on: expires_on
      )
    end

    context "when no conformity certificate exists" do
      it "returns nil for the expiry date" do
        expect(payload["conformity_certificate_expires_on"]).to be_nil
      end

      it "returns nil for days_remaining" do
        expect(payload["conformity_certificate_days_remaining"]).to be_nil
      end
    end

    context "when a conformity certificate exists" do
      before { create_doc(expires_on: future_date) }

      it "returns conformity_certificate_expires_on as an ISO 8601 date" do
        expect(payload["conformity_certificate_expires_on"]).to eq(future_date.iso8601)
      end

      it "returns a positive conformity_certificate_days_remaining" do
        expect(payload["conformity_certificate_days_remaining"]).to be > 0
      end
    end

    context "when the certificate document is discarded" do
      before { create_doc(expires_on: future_date).discard }

      it "excludes the discarded document" do
        expect(payload["conformity_certificate_expires_on"]).to be_nil
      end
    end
  end
end
