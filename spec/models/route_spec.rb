require "rails_helper"

RSpec.describe Route do
  let(:route) do
    described_class.new(origin: "Conakry", destination: "Labe", rate_cents: 250_000)
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "is valid with origin, destination, rate_cents" do
    expect(route).to be_valid
  end

  it "requires origin" do
    route.origin = nil
    route.validate
    expect(route.errors[:origin]).to be_present
  end

  it "requires destination" do
    route.destination = nil
    route.validate
    expect(route.errors[:destination]).to be_present
  end

  it "requires non-negative rate_cents" do
    route.rate_cents = -1
    route.validate
    expect(route.errors[:rate_cents]).to be_present
  end

  it "enforces case-insensitive uniqueness of (origin, destination)" do
    described_class.create!(origin: "Conakry", destination: "Labe", rate_cents: 250_000)
    duplicate = described_class.new(origin: "conakry", destination: "labe", rate_cents: 300_000)
    duplicate.validate
    expect(duplicate.errors[:origin]).to be_present
  end

  it "allows the same origin with a different destination" do
    described_class.create!(origin: "Conakry", destination: "Labe", rate_cents: 250_000)
    other = described_class.new(origin: "Conakry", destination: "Kindia", rate_cents: 150_000)
    expect(other).to be_valid
  end

  it "associates has_many :trips" do
    expect(described_class.reflect_on_association(:trips).macro).to eq(:has_many)
  end

  it "does not hard-destroy on discard" do
    route.save!
    route.discard
    expect(described_class.find(route.id)).to be_discarded
  end
end
