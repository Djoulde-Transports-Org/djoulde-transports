# frozen_string_literal: true

RSpec.describe API::V1::Entities::Maintenance do
  let(:truck)       { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance) do
    Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :repair, state: :completed,
                        estimated_duration: 3.0, actual_duration: 2.5)
  end
  let(:payload) { described_class.represent(maintenance).as_json }

  before { maintenance.parts.create!(name: "brake pads", price: 1100) }

  it "exposes the id" do
    expect(payload[:id]).to eq(maintenance.id)
  end

  it "exposes the truck_id" do
    expect(payload[:truck_id]).to eq(truck.id)
  end

  it "exposes the kind" do
    expect(payload[:kind]).to eq("repair")
  end

  it "exposes the state" do
    expect(payload[:state]).to eq("completed")
  end

  it "exposes the estimated_duration" do
    expect(payload[:estimated_duration].to_f).to eq(3.0)
  end

  it "exposes the actual_duration" do
    expect(payload[:actual_duration].to_f).to eq(2.5)
  end

  it "exposes the parts as objects" do
    expect(payload[:parts].map { |p| [ p[:name], p[:price] ] }).to contain_exactly([ "brake pads", 1100 ])
  end

  it "excludes discarded parts" do
    maintenance.parts.first.discard
    expect(payload[:parts]).to be_empty
  end

  it "renders performed_on as a date" do
    expect(payload[:performed_on]).to eq(Time.zone.today.iso8601)
  end
end
