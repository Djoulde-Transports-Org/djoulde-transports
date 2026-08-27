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

  describe "documentable_label" do
    it "is the plate number for a Truck" do
      expect(payload[:documentable_label]).to eq(truck.plate_number)
    end

    it "is the plate number for a Tank" do
      tank_truck = Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}")
      tank = Tank.create!(truck: tank_truck, plate_number: "TK-#{SecureRandom.hex(2)}", capacity: 30_000)
      doc  = Document.create!(documentable: tank, number: "TNK-1", title: "Baremage")

      expect(described_class.represent(doc).as_json[:documentable_label]).to eq(tank.plate_number)
    end

    it "is the full_name for an Employee" do
      employee = Employee.create!(first_name: "Mamadou", last_name: "Diallo")
      doc      = Document.create!(documentable: employee, number: "LIC-1", title: "Permis")

      expect(described_class.represent(doc).as_json[:documentable_label]).to eq("Mamadou Diallo")
    end

    it "is the linked truck's plate number for a Maintenance" do
      maintenance = Maintenance.create!(truck: truck, performed_on: Date.new(2026, 1, 2))
      doc         = Document.create!(documentable: maintenance, number: "MNT-1", title: "Facture")

      expect(described_class.represent(doc).as_json[:documentable_label]).to eq(truck.plate_number)
    end

    it "is the delivery note number for a Trip that has one" do
      Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(2)}", capacity: 30_000)
      route = Route.create!(origin: "Conakry", destination: "Labe", rate: 250)
      trip  = Trip.create!(truck: truck, route: route)
      DeliveryNote.create!(trip: trip, number: "DN-42", gasoline_quantity: 0, diesel_quantity: 5_000)
      doc = Document.create!(documentable: trip, number: "TRP-1", title: "Bon")

      expect(described_class.represent(doc).as_json[:documentable_label]).to eq("DN-42")
    end

    it "is nil for a Trip with no delivery note" do
      Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(2)}", capacity: 30_000)
      route = Route.create!(origin: "Conakry", destination: "Labe", rate: 250)
      trip  = Trip.create!(truck: truck, route: route)
      doc   = Document.create!(documentable: trip, number: "TRP-2", title: "Bon")

      expect(described_class.represent(doc).as_json[:documentable_label]).to be_nil
    end

    it "is nil for a BillingStatement" do
      statement = BillingStatement.create!(number: "BS-1", month: Date.new(2026, 6, 1))
      doc       = Document.create!(documentable: statement, number: "BIL-1", title: "Facture")

      expect(described_class.represent(doc).as_json[:documentable_label]).to be_nil
    end

    it "uses the batched lookups over live association queries when both are provided" do
      maintenance = Maintenance.create!(truck: truck, performed_on: Date.new(2026, 1, 2))
      doc         = Document.create!(documentable: maintenance, number: "MNT-2", title: "Facture")

      result = described_class.represent(
        doc, truck_plates_by_maintenance_id: {maintenance.id => "OVERRIDDEN"}
      ).as_json
      expect(result[:documentable_label]).to eq("OVERRIDDEN")
    end
  end

  describe "documentable_date" do
    it "is the covered month for a BillingStatement" do
      statement = BillingStatement.create!(number: "BS-2", month: Date.new(2026, 6, 1))
      doc       = Document.create!(documentable: statement, number: "BIL-2", title: "Facture")

      expect(described_class.represent(doc).as_json[:documentable_date]).to eq("2026-06-01")
    end

    it "is nil for other documentable types" do
      expect(payload[:documentable_date]).to be_nil
    end
  end
end
