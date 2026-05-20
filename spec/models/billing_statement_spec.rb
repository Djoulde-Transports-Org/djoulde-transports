require "rails_helper"

RSpec.describe BillingStatement do
  let(:period) do
    BillingPeriod.create!(label: "2026-Q1", starts_on: Date.new(2026, 1, 1), ends_on: Date.new(2026, 3, 31))
  end
  let(:statement) do
    described_class.new(billing_period: period, number: "INV-0001")
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "requires billing_period" do
    blank = described_class.new(number: "INV-X")
    blank.validate
    expect(blank.errors[:billing_period]).to be_present
  end

  it "requires number" do
    statement.number = nil
    statement.validate
    expect(statement.errors[:number]).to be_present
  end

  it "enforces unique number" do
    statement.save!
    duplicate = described_class.new(billing_period: period, number: "INV-0001")
    duplicate.validate
    expect(duplicate.errors[:number]).to be_present
  end

  it "defaults status to draft" do
    statement.save!
    expect(statement.status).to eq("draft")
  end

  it "defaults total_cents to 0" do
    statement.save!
    expect(statement.total_cents).to eq(0)
  end

  it "has_many :billing_line_items" do
    expect(described_class.reflect_on_association(:billing_line_items).macro).to eq(:has_many)
  end

  it "does not hard-destroy on discard" do
    statement.save!
    statement.discard
    expect(described_class.find(statement.id)).to be_discarded
  end
end
