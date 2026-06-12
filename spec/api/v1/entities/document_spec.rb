# frozen_string_literal: true

RSpec.describe API::V1::Entities::Document do
  let(:truck)    { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:document) do
    Document.create!(documentable: truck, number: "INS-1", title: "Insurance", doc_type: :insurance,
                     issued_on: Date.new(2026, 1, 1))
  end
  let(:payload) { described_class.represent(document).as_json }

  it "exposes the id" do
    expect(payload[:id]).to eq(document.id)
  end

  it "exposes the polymorphic owner", :aggregate_failures do
    expect(payload[:documentable_type]).to eq("Truck")
    expect(payload[:documentable_id]).to eq(truck.id)
  end

  it "exposes the doc_type" do
    expect(payload[:doc_type]).to eq("insurance")
  end

  it "exposes the number" do
    expect(payload[:number]).to eq("INS-1")
  end

  it "renders issued_on as a date" do
    expect(payload[:issued_on]).to eq("2026-01-01")
  end

  it "reports whether a file is attached" do
    expect(payload[:file_attached]).to be false
  end

  it "renders created_at as a full ISO 8601 datetime" do
    expect(payload[:created_at]).to match(/\dT\d.*(Z|[+-]\d\d:\d\d)/)
  end
end
