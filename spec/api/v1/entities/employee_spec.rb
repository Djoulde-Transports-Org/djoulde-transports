# frozen_string_literal: true

RSpec.describe API::V1::Entities::Employee do
  let(:user)     { User.create!(email: "driver@example.com", password: "password123") }
  let(:employee) do
    Employee.create!(first_name: "Mamadou", last_name: "Diallo",
                     phone_number: "+224 620 000 000", address: "12 Rue du Port, Conakry",
                     hire_date: Date.new(2024, 3, 1), role: :driver, status: :active, user: user)
  end
  let(:payload) { described_class.represent(employee).as_json }

  it "exposes id" do
    expect(payload[:id]).to eq(employee.id)
  end

  it "exposes first_name" do
    expect(payload[:first_name]).to eq("Mamadou")
  end

  it "exposes last_name" do
    expect(payload[:last_name]).to eq("Diallo")
  end

  it "exposes full_name as first and last name combined" do
    expect(payload[:full_name]).to eq("Mamadou Diallo")
  end

  it "exposes phone_number" do
    expect(payload[:phone_number]).to eq("+224 620 000 000")
  end

  it "exposes address" do
    expect(payload[:address]).to eq("12 Rue du Port, Conakry")
  end

  it "exposes hire_date" do
    expect(payload[:hire_date]).to eq("2024-03-01")
  end

  it "exposes role as a string" do
    expect(payload[:role]).to eq("driver")
  end

  it "exposes status as a string" do
    expect(payload[:status]).to eq("active")
  end

  it "exposes user_id" do
    expect(payload[:user_id]).to eq(user.id)
  end

  it "exposes user_id as nil when no user is linked" do
    no_user_employee = Employee.create!(first_name: "Ibra", last_name: "Sow")
    result = described_class.represent(no_user_employee).as_json
    expect(result[:user_id]).to be_nil
  end

  it "exposes assigned_truck as nil when no truck is assigned" do
    expect(payload[:assigned_truck]).to be_nil
  end

  it "exposes assigned_truck when a truck is assigned" do
    truck = Truck.create!(plate_number: "RC-1234-A", driver: employee)
    result = described_class.represent(employee.reload).as_json
    expect(result[:assigned_truck]).to eq({id: truck.id, plate_number: "RC-1234-A"})
  end
end
