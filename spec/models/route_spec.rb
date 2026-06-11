# frozen_string_literal: true

RSpec.describe Route do
  let(:route) do
    described_class.new(origin: "Conakry", destination: "Labe", rate: 250)
  end

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "is valid with origin, destination, rate" do
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

  it "requires non-negative rate" do
    route.rate = -1
    route.validate
    expect(route.errors[:rate]).to be_present
  end

  it "allows a fractional rate" do
    route.rate = 1160.59
    route.validate
    expect(route.errors[:rate]).to be_empty
  end

  it "persists the decimal part of the rate" do
    route.rate = 1160.59
    route.save!
    expect(route.reload.rate).to eq(BigDecimal("1160.59"))
  end

  it "enforces case-insensitive uniqueness of (origin, destination)" do
    described_class.create!(origin: "Conakry", destination: "Labe", rate: 250)
    duplicate = described_class.new(origin: "conakry", destination: "labe", rate: 300)
    duplicate.validate
    expect(duplicate.errors[:origin]).to be_present
  end

  it "allows the same origin with a different destination" do
    described_class.create!(origin: "Conakry", destination: "Labe", rate: 250)
    other = described_class.new(origin: "Conakry", destination: "Kindia", rate: 150)
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
