# frozen_string_literal: true

RSpec.describe API::V1::Entities::MaintenanceKind do
  let(:maintenance_kind) { MaintenanceKind.create!(name: "repair") }
  let(:payload) { described_class.represent(maintenance_kind).as_json }

  it "exposes the id" do
    expect(payload[:id]).to eq(maintenance_kind.id)
  end

  it "exposes the name" do
    expect(payload[:name]).to eq("repair")
  end
end
