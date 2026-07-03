# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::Discard do
  let(:employee) { Employee.create!(first_name: "Mamadou", last_name: "Diallo", role: :driver) }

  it "discards the employee" do
    described_class.call(employee)
    expect(employee.reload.discarded?).to be true
  end

  it "cascades discard to kept documents" do
    document = Document.create!(documentable: employee, number: "LIC-1",
                                title: "Driver Licence", issued_on: Date.current - 365,
                                expires_on: Date.current + 365)
    described_class.call(employee)
    expect(document.reload.discarded?).to be true
  end

  it "does not cascade to already-discarded documents" do
    document = Document.create!(documentable: employee, number: "LIC-2",
                                title: "Driver Licence", issued_on: Date.current - 365,
                                expires_on: Date.current + 365)
    document.discard
    # calling discard! on an already-discarded record would raise; if it doesn't raise here,
    # the service correctly skips it
    expect { described_class.call(employee) }.not_to raise_error
  end

  it "clears driver_id on the employee's assigned truck" do
    truck = Truck.create!(plate_number: "GN-#{SecureRandom.hex(3)}", make: "Volvo",
                          model: "FH", year: 2020, driver: employee)
    described_class.call(employee)
    expect(truck.reload.driver_id).to be_nil
  end

  it "does not raise when the employee has no truck assignment" do
    expect { described_class.call(employee) }.not_to raise_error
  end

  describe "the returned result" do
    let(:result) { described_class.call(employee) }

    it "is an Employees::Discard::Result" do
      expect(result).to be_a(Employees::Discard::Result)
    end

    it "is successful" do
      expect(result.success).to be true
    end

    it "carries a success message" do
      expect(result.message).to eq("Employee has been successfully deleted.")
    end
  end
end
