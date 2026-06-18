# frozen_string_literal: true

# Builders for valid records used by the per-resource admin request specs.
# Each returns a persisted record with the minimum required attributes.
module AdminRecords
  def build_route
    Route.create!(origin: "Conakry", destination: "Labe", rate: 250)
  end

  def build_truck
    Truck.create!(plate_number: "TRK-#{SecureRandom.hex(3)}", year: 2020)
  end

  def build_tank(truck: build_truck)
    Tank.create!(truck: truck, plate_number: "TNK-#{SecureRandom.hex(3)}",
      capacity: 30_000, year: 2020)
  end

  def build_trip(truck: build_truck, route: build_route, tank: nil)
    Trip.create!(truck: truck, tank: tank || build_tank(truck: truck), route: route)
  end

  def build_delivery_note(trip: build_trip)
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(3)}",
      gasoline_quantity: 10_000, diesel_quantity: 5_000, missing_quantity: 0)
  end

  def build_billing_statement(month: Date.new(2026, 1, 1))
    BillingStatement.create!(number: "BS-#{SecureRandom.hex(3)}", month: month)
  end

  def build_billing_line_item(statement: build_billing_statement, trip: build_trip)
    BillingLineItem.create!(billing_statement: statement, trip: trip,
      amount: 1_000, tva: 180, rate: 250, gasoline_quantity: 0, diesel_quantity: 0,
      origin: "Conakry", destination: "Labe")
  end

  def build_maintenance(truck: build_truck)
    Maintenance.create!(truck: truck, performed_on: Date.new(2026, 1, 2))
  end

  def build_maintenance_part(maintenance: build_maintenance)
    MaintenancePart.create!(maintenance: maintenance, name: "Oil filter", price: 50)
  end

  def build_document(documentable: build_truck)
    Document.create!(documentable: documentable, doc_type: :other,
      number: "DOC-#{SecureRandom.hex(3)}", title: "Sample document")
  end

  def build_role
    Role.create!(name: "tester-#{SecureRandom.hex(3)}")
  end
end

RSpec.configure do |config|
  config.include AdminRecords, type: :request
end
