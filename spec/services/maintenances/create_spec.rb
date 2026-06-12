# frozen_string_literal: true

require "rails_helper"

RSpec.describe Maintenances::Create do
  let(:truck) { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance_params) { {truck: truck, performed_on: Time.zone.today, kind: :repair} }
  let(:parts_params) { [ {name: "filter", price: 1100}, {name: "belt", price: 800} ] }

  it "creates the maintenance" do
    expect { described_class.call(maintenance_params, parts_params) }
      .to change { Maintenance.count }.by(1)
  end

  it "moves the truck into the in_maintenance status" do
    described_class.call(maintenance_params, parts_params)
    expect(truck.reload).to be_in_maintenance
  end

  it "creates a part per entry" do
    maintenance = described_class.call(maintenance_params, parts_params)
    expect(maintenance.parts.pluck(:name, :price)).to contain_exactly([ "filter", 1100 ], [ "belt", 800 ])
  end

  it "creates no parts when none are supplied" do
    maintenance = described_class.call(maintenance_params)
    expect(maintenance.parts).to be_empty
  end

  it "sets the cost to the sum of the part prices" do
    maintenance = described_class.call(maintenance_params, parts_params)
    expect(maintenance.cost).to eq(1900)
  end

  it "sets the cost to zero when no parts are supplied" do
    maintenance = described_class.call(maintenance_params)
    expect(maintenance.cost).to eq(0)
  end

  it "rolls back the maintenance when a part is invalid" do
    expect {
      begin
        described_class.call(maintenance_params, [ {name: "", price: 100} ])
      rescue ActiveRecord::RecordInvalid
        nil
      end
    }.not_to change { Maintenance.count }
  end
end
