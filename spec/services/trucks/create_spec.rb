# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucks::Create do
  let(:creator) { User.create!(email: "admin@example.com", password: "password123") }
  let(:truck_attrs) { {plate_number: "NEW-#{SecureRandom.hex(2)}", model: "FH", year: 2022} }
  let(:tank_attrs) { {plate_number: "TK-#{SecureRandom.hex(2)}", capacity: 30_000} }

  def call(**overrides)
    described_class.call(truck_attrs: truck_attrs, tank_attrs: tank_attrs, created_by: creator, **overrides)
  end

  it "creates a truck and its tank" do
    expect { call }.to change { Truck.count }.by(1).and change { Tank.count }.by(1)
  end

  it "creates the tank without vin, make, model or year" do
    result = call
    expect(result.tank.plate_number).to eq(tank_attrs[:plate_number])
  end

  context "without a last_oil_change_on" do
    it "does not create a maintenance" do
      expect { call }.not_to change { Maintenance.count }
    end
  end

  context "with a last_oil_change_on" do
    it "creates a completed oil-change maintenance" do
      result = call(last_oil_change_on: Date.new(2026, 1, 15))
      maintenance = result.maintenances.sole
      expect(maintenance).to have_attributes(kind: "oil_change", state: "completed", performed_on: Date.new(2026, 1, 15))
    end
  end

  context "without document_expiries" do
    it "does not create any documents" do
      expect { call }.not_to change { Document.count }
    end
  end

  context "with document_expiries" do
    let(:document_expiries) do
      {
        truck_insurance_expires_on:      Date.new(2027, 1, 1),
        cargo_insurance_expires_on:      Date.new(2027, 2, 1),
        technical_inspection_expires_on: Date.new(2027, 3, 1),
        operating_permit_expires_on:     Date.new(2027, 4, 1),
        truck_registration_expires_on:   Date.new(2027, 5, 1),
      }
    end

    it "creates a document per provided expiry" do
      expect { call(document_expiries: document_expiries) }.to change { Document.count }.by(5)
    end

    it "maps each param to the right doc_type and expiry", :aggregate_failures do
      result = call(document_expiries: document_expiries)
      docs = result.documents.index_by(&:doc_type)

      expect(docs["truck_insurance"].expires_on).to eq(Date.new(2027, 1, 1))
      expect(docs["product_insurance"].expires_on).to eq(Date.new(2027, 2, 1))
      expect(docs["technical_inspection"].expires_on).to eq(Date.new(2027, 3, 1))
      expect(docs["transport_card"].expires_on).to eq(Date.new(2027, 4, 1))
      expect(docs["truck_registration"].expires_on).to eq(Date.new(2027, 5, 1))
    end

    it "skips blank expiries" do
      result = call(document_expiries: document_expiries.merge(truck_insurance_expires_on: nil))
      expect(result.documents.count).to eq(4)
    end
  end
end
