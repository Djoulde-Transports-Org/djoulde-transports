# frozen_string_literal: true

RSpec.describe Maintenance do
  let(:truck) { Truck.create!(plate_number: "MNT-1") }
  let(:maintenance) do
    described_class.new(truck: truck, performed_on: Time.zone.today)
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

  it "defaults state to started" do
    expect(described_class.new.state).to eq("started")
  end

  it "rejects negative actual_duration" do
    maintenance.actual_duration = -1
    maintenance.validate
    expect(maintenance.errors[:actual_duration]).to be_present
  end

  it "rejects negative estimated_duration" do
    maintenance.estimated_duration = -1
    maintenance.validate
    expect(maintenance.errors[:estimated_duration]).to be_present
  end

  it "has many parts" do
    maintenance.save!
    part = maintenance.parts.create!(name: "filter", price: 1100)
    expect(maintenance.parts).to include(part)
  end

  describe "#recompute_cost!" do
    before { maintenance.save! }

    it "sets the cost to the sum of the kept parts' prices" do
      maintenance.parts.create!(name: "filter", price: 1100)
      maintenance.parts.create!(name: "belt", price: 800)
      maintenance.recompute_cost!
      expect(maintenance.cost).to eq(1900)
    end

    it "ignores discarded parts" do
      maintenance.parts.create!(name: "filter", price: 1100)
      maintenance.parts.create!(name: "belt", price: 800).discard
      maintenance.recompute_cost!
      expect(maintenance.cost).to eq(1100)
    end

    it "is zero when there are no kept parts" do
      maintenance.recompute_cost!
      expect(maintenance.cost).to eq(0)
    end
  end

  it "does not hard-destroy on discard" do
    maintenance.save!
    maintenance.discard
    expect(described_class.find(maintenance.id)).to be_discarded
  end
end
