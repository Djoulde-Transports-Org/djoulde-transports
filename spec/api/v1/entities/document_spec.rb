# frozen_string_literal: true

RSpec.describe API::V1::Entities::Document do
  let(:truck)    { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:document) do
    Document.create!(documentable: truck, number: "INS-1", title: "Insurance", doc_type: :truck_insurance,
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
    expect(payload[:doc_type]).to eq("truck_insurance")
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

  it "exposes created_at as an ISO 8601 datetime" do
    expect(payload[:created_at]).to eq(document.created_at.iso8601)
  end

  it "exposes file_size as nil when no file is attached" do
    expect(payload[:file_size]).to be_nil
  end

  it "exposes uploaded_by as nil when no one uploaded the document" do
    expect(payload[:uploaded_by]).to be_nil
  end

  it "exposes the uploader's employee full_name when the uploaded_by user has a linked employee" do
    user = User.create!(email: "uploader@example.com", password: "password123")
    Employee.create!(first_name: "Mamadou", last_name: "Diallo", user: user)
    document.update!(uploaded_by: user)

    result = described_class.represent(document.reload).as_json
    expect(result[:uploaded_by]).to eq({id: user.id, name: "Mamadou Diallo"})
  end

  it "exposes the uploader's email when the uploaded_by user has no linked employee" do
    user = User.create!(email: "uploader@example.com", password: "password123")
    document.update!(uploaded_by: user)

    result = described_class.represent(document.reload).as_json
    expect(result[:uploaded_by]).to eq({id: user.id, name: "uploader@example.com"})
  end
end
