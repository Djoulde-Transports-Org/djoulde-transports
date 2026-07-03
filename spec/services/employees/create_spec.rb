# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::Create do
  let(:creator) { User.create!(email: "admin@example.com", password: "password123") }
  let(:attrs)   { {first_name: "Mamadou", last_name: "Diallo", role: :driver} }

  it "creates an employee" do
    expect { described_class.call(attrs: attrs, created_by: creator) }
      .to change { Employee.count }.by(1)
  end

  it "returns the created employee" do
    result = described_class.call(attrs: attrs, created_by: creator)
    expect(result).to be_a(Employee)
  end

  it "stamps created_by" do
    result = described_class.call(attrs: attrs, created_by: creator)
    expect(result.created_by).to eq(creator)
  end

  it "applies the given attributes", :aggregate_failures do
    result = described_class.call(attrs: attrs, created_by: creator)
    expect(result.first_name).to eq("Mamadou")
    expect(result.last_name).to eq("Diallo")
    expect(result.role).to eq("driver")
  end

  it "links a user account when user_id is provided" do
    user   = User.create!(email: "driver@example.com", password: "password123")
    result = described_class.call(attrs: attrs.merge(user_id: user.id), created_by: creator)
    expect(result.user).to eq(user)
  end

  it "raises ActiveRecord::RecordInvalid when first_name is blank" do
    expect { described_class.call(attrs: attrs.merge(first_name: ""), created_by: creator) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
