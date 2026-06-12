# frozen_string_literal: true

RSpec.describe BillingStatement do
  let(:statement_month) { Date.new(2026, 5, 1) }
  let(:statement) { described_class.new(number: "INV-202605", month: statement_month) }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "requires number" do
    statement.number = nil
    statement.validate
    expect(statement.errors[:number]).to be_present
  end

  it "requires month" do
    statement.month = nil
    statement.validate
    expect(statement.errors[:month]).to be_present
  end

  it "rejects a month that is not the first of the month" do
    statement.month = Date.new(2026, 5, 15)
    statement.validate
    expect(statement.errors[:month]).to be_present
  end

  it "derives starts_on and ends_on from month" do
    statement.save!
    expect([ statement.starts_on, statement.ends_on ])
      .to eq([ statement_month, Date.new(2026, 5, 31) ])
  end

  it "enforces unique number" do
    statement.save!
    duplicate = described_class.new(number: "INV-202605", month: Date.new(2026, 6, 1))
    duplicate.validate
    expect(duplicate.errors[:number]).to be_present
  end

  it "enforces one statement per month" do
    statement.save!
    duplicate = described_class.new(number: "INV-202605-B", month: statement_month)
    duplicate.validate
    expect(duplicate.errors[:month]).to be_present
  end

  it "defaults status to draft" do
    statement.save!
    expect(statement.status).to eq("draft")
  end

  it "defaults total_amount to 0" do
    statement.save!
    expect(statement.total_amount).to eq(0)
  end

  describe "issue window (1st-10th of month + 1)" do
    it "accepts issued_on on the 1st of the following month" do
      statement.issued_on = Date.new(2026, 6, 1)
      expect(statement).to be_valid
    end

    it "accepts issued_on on the 10th of the following month" do
      statement.issued_on = Date.new(2026, 6, 10)
      expect(statement).to be_valid
    end

    it "rejects issued_on inside the billed month" do
      statement.issued_on = Date.new(2026, 5, 31)
      statement.validate
      expect(statement.errors[:issued_on]).to be_present
    end

    it "rejects issued_on after the 10th" do
      statement.issued_on = Date.new(2026, 6, 11)
      statement.validate
      expect(statement.errors[:issued_on]).to be_present
    end
  end

  describe ".for_month" do
    it "returns the statement for the given month" do
      statement.save!
      expect(described_class.for_month(Date.new(2026, 5, 14))).to contain_exactly(statement)
    end
  end

  describe ".due_for_issue" do
    it "returns draft statements whose billed month has ended" do
      statement.save!
      expect(described_class.due_for_issue(Date.new(2026, 6, 5))).to contain_exactly(statement)
    end

    it "excludes draft statements whose billed month is still in progress" do
      statement.save!
      expect(described_class.due_for_issue(Date.new(2026, 5, 31))).to be_empty
    end
  end

  describe "#recalculate_total!" do
    let(:line) do
      truck = build_truck_with_tank(plate: "BS-1")
      route = Route.create!(origin: "A", destination: "B", rate: 250)
      trip  = Trip.create!(truck: truck, route: route, actual_start_at: Time.zone.local(2026, 5, 2))
      DeliveryNote.create!(trip: trip, number: "DN-BS-1",
                           gasoline_quantity: 1_000, diesel_quantity: 500,
                           delivered_on: Date.new(2026, 5, 2))
      BillingLineItem.from_trip(trip, billing_statement: statement)
    end

    it "sums amounts onto total_amount and tva onto total_tva" do
      statement.save!
      line.save!
      statement.recalculate_total!
      expect([ statement.total_amount, statement.total_tva ])
        .to eq([ 375_000, 67_500 ])
    end

    it "writes grand_total as total_amount + total_tva" do
      statement.save!
      line.save!
      statement.recalculate_total!
      expect(statement.grand_total).to eq(442_500)
    end
  end

  it "does not hard-destroy on discard" do
    statement.save!
    statement.discard
    expect(described_class.find(statement.id)).to be_discarded
  end
end
