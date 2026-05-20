require "rails_helper"

RSpec.describe BillingPeriod do
  let(:period) do
    described_class.new(label: "2026-Q1", starts_on: Date.new(2026, 1, 1), ends_on: Date.new(2026, 3, 31))
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "requires label" do
    blank = described_class.new
    blank.validate
    expect(blank.errors[:label]).to be_present
  end

  it "requires starts_on" do
    blank = described_class.new
    blank.validate
    expect(blank.errors[:starts_on]).to be_present
  end

  it "requires ends_on" do
    blank = described_class.new
    blank.validate
    expect(blank.errors[:ends_on]).to be_present
  end

  it "enforces unique labels" do
    period.save!
    duplicate = described_class.new(label: "2026-Q1", starts_on: period.starts_on, ends_on: period.ends_on)
    duplicate.validate
    expect(duplicate.errors[:label]).to be_present
  end

  it "rejects ends_on before starts_on" do
    period.ends_on = period.starts_on - 1
    period.validate
    expect(period.errors[:ends_on]).to be_present
  end

  it "defaults status to open" do
    period.save!
    expect(period.status).to eq("open")
  end

  it "does not hard-destroy on discard" do
    period.save!
    period.discard
    expect(described_class.find(period.id)).to be_discarded
  end
end
