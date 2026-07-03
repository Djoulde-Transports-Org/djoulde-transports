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
end
