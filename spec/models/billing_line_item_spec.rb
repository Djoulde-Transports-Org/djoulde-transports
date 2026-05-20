require "rails_helper"

RSpec.describe BillingLineItem do
  let(:period) do
    BillingPeriod.create!(label: "2026-Q2", starts_on: Date.new(2026, 4, 1), ends_on: Date.new(2026, 6, 30))
  end
  let(:statement) { BillingStatement.create!(billing_period: period, number: "INV-1001") }
  let(:line_item) do
    described_class.new(billing_statement: statement, description: "Trip Conakry to Labe",
                        quantity: 1, unit_price_cents: 5_000, amount_cents: 5_000)
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited and associated with billing_statement" do
    expect(described_class.audited_options[:associated_with]).to eq(:billing_statement)
  end

  it "requires description" do
    line_item.description = nil
    line_item.validate
    expect(line_item.errors[:description]).to be_present
  end

  it "rejects zero quantity" do
    line_item.quantity = 0
    line_item.validate
    expect(line_item.errors[:quantity]).to be_present
  end

  it "rejects negative unit_price_cents" do
    line_item.unit_price_cents = -1
    line_item.validate
    expect(line_item.errors[:unit_price_cents]).to be_present
  end

  it "does not hard-destroy on discard" do
    line_item.save!
    line_item.discard
    expect(described_class.find(line_item.id)).to be_discarded
  end
end
