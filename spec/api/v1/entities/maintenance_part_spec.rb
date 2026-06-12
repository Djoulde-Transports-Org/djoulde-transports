# frozen_string_literal: true

RSpec.describe API::V1::Entities::MaintenancePart do
  let(:truck)       { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance) { Maintenance.create!(truck: truck, performed_on: Time.zone.today) }
  let(:part)        { maintenance.parts.create!(name: "filter", price: 1100) }
  let(:payload)     { described_class.represent(part).as_json }

  it "exposes the id" do
    expect(payload[:id]).to eq(part.id)
  end

  it "exposes the name" do
    expect(payload[:name]).to eq("filter")
  end

  it "exposes the price" do
    expect(payload[:price]).to eq(1100)
  end
end
