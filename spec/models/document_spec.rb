# frozen_string_literal: true

RSpec.describe Document do
  let(:truck) { build_truck_with_tank(plate: "DOC-1") }
  let(:document) { described_class.new(number: "INS-1", title: "Insurance card", documentable: truck) }

  it "includes Discardable" do
    expect(described_class.included_modules).to include(Discardable)
  end

  it "is audited" do
    expect(described_class.audited_options).to be_present
  end

  it "is polymorphic on documentable" do
    reflection = described_class.reflect_on_association(:documentable)
    expect(reflection.options[:polymorphic]).to be(true)
  end

  it "has_one_attached :file (Active Storage)" do
    expect(document).to respond_to(:file)
  end

  it "requires title" do
    document.title = nil
    document.validate
    expect(document.errors[:title]).to be_present
  end

  it "requires number" do
    document.number = nil
    document.validate
    expect(document.errors[:number]).to be_present
  end

  it "rejects expires_on earlier than issued_on" do
    document.issued_on  = Time.zone.today
    document.expires_on = Time.zone.today - 1
    document.validate
    expect(document.errors[:expires_on]).to be_present
  end

  it "can attach to a Trip via documentable" do
    route = Route.create!(origin: "A", destination: "B", rate: 100)
    trip  = Trip.create!(truck: truck, route: route)
    doc   = described_class.create!(number: "BOL-1", title: "Bill of lading", documentable: trip)
    expect(trip.documents).to include(doc)
  end

  it "does not hard-destroy on discard" do
    document.save!
    document.discard
    expect(described_class.find(document.id)).to be_discarded
  end
end
