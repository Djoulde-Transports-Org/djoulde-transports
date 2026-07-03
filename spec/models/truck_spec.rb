# frozen_string_literal: true

RSpec.describe Truck do
  let(:truck) { described_class.new(plate_number: "ABC-123") }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "is valid with a plate_number" do
    expect(truck).to be_valid
  end

  it "requires plate_number" do
    truck.plate_number = nil
    truck.validate
    expect(truck.errors[:plate_number]).to be_present
  end

  it "enforces case-insensitive plate_number uniqueness" do
    described_class.create!(plate_number: "ABC-123")
    duplicate = described_class.new(plate_number: "abc-123")
    duplicate.validate
    expect(duplicate.errors[:plate_number]).to be_present
  end

  it "defaults status to ready" do
    truck.save!
    expect(truck.status).to eq("ready")
  end

  it "belongs_to driver (Employee, optional)", :aggregate_failures do
    reflection = described_class.reflect_on_association(:driver)
    expect(reflection.macro).to eq(:belongs_to)
    expect(reflection.options[:class_name]).to eq("Employee")
    expect(reflection.options[:optional]).to be true
  end

  it "accepts a driver assignment" do
    employee = Employee.create!(first_name: "Mamadou", last_name: "Diallo")
    truck.save!
    truck.update!(driver: employee)
    expect(truck.reload.driver).to eq(employee)
  end

  it "associates has_many :trips" do
    expect(described_class.reflect_on_association(:trips).macro).to eq(:has_many)
  end

  it "associates has_many :maintenances" do
    expect(described_class.reflect_on_association(:maintenances).macro).to eq(:has_many)
  end

  it "associates has_many :documents as :documentable" do
    reflection = described_class.reflect_on_association(:documents)
    expect(reflection.options[:as]).to eq(:documentable)
  end

  it "does not hard-destroy on discard" do
    truck.save!
    truck.discard
    expect(described_class.find(truck.id)).to be_discarded
  end
end
