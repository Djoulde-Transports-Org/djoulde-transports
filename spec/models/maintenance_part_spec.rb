# frozen_string_literal: true

RSpec.describe MaintenancePart do
  let(:truck)       { Truck.create!(plate_number: "MNT-#{SecureRandom.hex(2)}") }
  let(:maintenance) { Maintenance.create!(truck: truck, performed_on: Time.zone.today) }
  let(:part)        { described_class.new(maintenance: maintenance, name: "filter", price: 1100) }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "requires a maintenance" do
    part.maintenance = nil
    part.validate
    expect(part.errors[:maintenance]).to be_present
  end

  it "requires a name" do
    part.name = nil
    part.validate
    expect(part.errors[:name]).to be_present
  end

  it "defaults price to 0" do
    expect(described_class.new.price).to eq(0)
  end

  it "rejects a negative price" do
    part.price = -1
    part.validate
    expect(part.errors[:price]).to be_present
  end

  it "does not hard-destroy on discard" do
    part.save!
    part.discard
    expect(described_class.find(part.id)).to be_discarded
  end
end
