# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::Update do
  let(:employee) { Employee.create!(first_name: "Mamadou", last_name: "Diallo", role: :driver) }

  it "updates the employee attributes" do
    described_class.call(employee, attrs: {last_name: "Barry"})
    expect(employee.reload.last_name).to eq("Barry")
  end

  it "returns the updated employee" do
    result = described_class.call(employee, attrs: {last_name: "Barry"})
    expect(result).to eq(employee)
  end

  it "updates the role" do
    described_class.call(employee, attrs: {role: :mechanic})
    expect(employee.reload.role).to eq("mechanic")
  end

  it "links a user account" do
    user = User.create!(email: "driver@example.com", password: "password123")
    described_class.call(employee, attrs: {user_id: user.id})
    expect(employee.reload.user).to eq(user)
  end

  it "updates the phone_number" do
    described_class.call(employee, attrs: {phone_number: "+224 620 111 111"})
    expect(employee.reload.phone_number).to eq("+224 620 111 111")
  end

  it "raises ActiveRecord::RecordInvalid when first_name is set to blank" do
    expect { described_class.call(employee, attrs: {first_name: ""}) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  it "updates address, hire_date and status", :aggregate_failures do
    described_class.call(
      employee,
      attrs: {address: "45 Avenue de la République, Kindia", hire_date: Date.new(2023, 9, 1),
              status: :inactive}
    )
    employee.reload
    expect(employee.address).to eq("45 Avenue de la République, Kindia")
    expect(employee.hire_date).to eq(Date.new(2023, 9, 1))
    expect(employee.status).to eq("inactive")
  end

  it "assigns a truck via truck_id" do
    truck = Truck.create!(plate_number: "GN-2000-B")
    described_class.call(employee, attrs: {truck_id: truck.id})
    expect(truck.reload.driver).to eq(employee)
  end

  it "clears the employee's previous truck when reassigned to a new one", :aggregate_failures do
    old_truck = Truck.create!(plate_number: "GN-3000-C", driver: employee)
    new_truck = Truck.create!(plate_number: "GN-4000-D")
    described_class.call(employee, attrs: {truck_id: new_truck.id})
    expect(old_truck.reload.driver).to be_nil
    expect(new_truck.reload.driver).to eq(employee)
  end

  it "unassigns the employee's truck when truck_id is set to nil" do
    truck = Truck.create!(plate_number: "GN-5000-E", driver: employee)
    described_class.call(employee, attrs: {truck_id: nil})
    expect(truck.reload.driver).to be_nil
  end

  it "does not touch truck assignment when truck_id is not provided" do
    truck = Truck.create!(plate_number: "GN-6000-F", driver: employee)
    described_class.call(employee, attrs: {last_name: "Barry"})
    expect(truck.reload.driver).to eq(employee)
  end
end
