# frozen_string_literal: true

RSpec.describe MaintenanceKind do
  let(:maintenance_kind) { described_class.new(name: "repair") }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "is valid with a name" do
    expect(maintenance_kind).to be_valid
  end

  it "requires a name" do
    maintenance_kind.name = nil
    maintenance_kind.validate
    expect(maintenance_kind.errors[:name]).to be_present
  end

  it "enforces case-insensitive uniqueness of name" do
    described_class.create!(name: "repair")
    duplicate = described_class.new(name: "Repair")
    duplicate.validate
    expect(duplicate.errors[:name]).to be_present
  end

  it "associates has_many :maintenances" do
    expect(described_class.reflect_on_association(:maintenances).macro).to eq(:has_many)
  end

  it "does not hard-destroy on discard" do
    maintenance_kind.save!
    maintenance_kind.discard
    expect(described_class.find(maintenance_kind.id)).to be_discarded
  end
end
