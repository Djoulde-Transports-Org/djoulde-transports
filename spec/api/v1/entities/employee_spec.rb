# frozen_string_literal: true

RSpec.describe API::V1::Entities::Employee do
  let(:user)     { User.create!(email: "driver@example.com", password: "password123") }
  let(:employee) do
    Employee.create!(first_name: "Mamadou", last_name: "Diallo",
                     phone_number: "+224 620 000 000", role: :driver, user: user)
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

  it "exposes role as a string" do
    expect(payload[:role]).to eq("driver")
  end

  it "exposes user_id" do
    expect(payload[:user_id]).to eq(user.id)
  end

  it "exposes user_id as nil when no user is linked" do
    no_user_employee = Employee.create!(first_name: "Ibra", last_name: "Sow")
    result = described_class.represent(no_user_employee).as_json
    expect(result[:user_id]).to be_nil
  end
end
