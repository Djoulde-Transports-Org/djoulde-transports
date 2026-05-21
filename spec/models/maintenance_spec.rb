# frozen_string_literal: true

require "rails_helper"

RSpec.describe Maintenance do
  let(:truck) { Truck.create!(plate_number: "MNT-1") }
  let(:maintenance) do
    described_class.new(truck: truck, performed_on: Time.zone.current)
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "requires a truck" do
    maintenance.truck = nil
    maintenance.validate
    expect(maintenance.errors[:truck]).to be_present
  end

  it "requires performed_on" do
    maintenance.performed_on = nil
    maintenance.validate
    expect(maintenance.errors[:performed_on]).to be_present
  end

  it "defaults kind to routine" do
    maintenance.save!
    expect(maintenance.kind).to eq("routine")
  end

  it "rejects negative cost" do
    maintenance.cost = -1
    maintenance.validate
    expect(maintenance.errors[:cost]).to be_present
  end

  it "does not hard-destroy on discard" do
    maintenance.save!
    maintenance.discard
    expect(described_class.find(maintenance.id)).to be_discarded
  end
end
