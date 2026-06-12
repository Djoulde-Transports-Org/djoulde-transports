# frozen_string_literal: true

require "rails_helper"

RSpec.describe Maintenances::Discard do
  let(:truck)       { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance) { Maintenance.create!(truck: truck, performed_on: Time.zone.today) }

  it "discards the maintenance record" do
    described_class.call(maintenance)
    expect(maintenance.reload.discarded?).to be true
  end

  it "cascades to documents" do
    document = Document.create!(documentable: maintenance, number: "RCP-1", title: "Receipt")
    described_class.call(maintenance)
    expect(document.reload.discarded?).to be true
  end

  describe "the returned result" do
    let(:result) { described_class.call(maintenance) }

    it "is a Maintenances::Discard::Result" do
      expect(result).to be_a(Maintenances::Discard::Result)
    end

    it "is successful" do
      expect(result.success).to be true
    end

    it "carries a success message" do
      expect(result.message).to eq("Maintenance has been successfully deleted.")
    end
  end
end
