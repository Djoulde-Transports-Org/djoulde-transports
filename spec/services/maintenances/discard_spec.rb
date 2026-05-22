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
    document = Document.create!(documentable: maintenance, title: "Receipt")
    described_class.call(maintenance)
    expect(document.reload.discarded?).to be true
  end
end
