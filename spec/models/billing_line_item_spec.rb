require "rails_helper"

RSpec.describe BillingLineItem do
  let(:statement) do
    BillingStatement.create!(number: "INV-202605", month: Date.new(2026, 5, 1))
  end
  let(:trip) do
    truck = Truck.create!(plate_number: "LI-1")
    route = Route.create!(origin: "Conakry", destination: "Labe", rate_cents: 250_000)
    Trip.create!(truck: truck, route: route, actual_start_at: Time.zone.local(2026, 5, 12))
  end
  let(:line_item) do
    described_class.new(billing_statement: statement, trip: trip,
                        description: "Conakry -> Labe", amount_cents: 250_000)
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

  it "requires a trip" do
    line_item.trip = nil
    line_item.validate
    expect(line_item.errors[:trip]).to be_present
  end

  it "rejects negative amount_cents" do
    line_item.amount_cents = -1
    line_item.validate
    expect(line_item.errors[:amount_cents]).to be_present
  end

  it "rejects two line items for the same trip on the same statement" do
    line_item.save!
    duplicate = line_item.dup.tap { |li| li.description = "duplicate" }
    duplicate.validate
    expect(duplicate.errors[:trip_id]).to be_present
  end

  it "does not hard-destroy on discard" do
    line_item.save!
    line_item.discard
    expect(described_class.find(line_item.id)).to be_discarded
  end
end
