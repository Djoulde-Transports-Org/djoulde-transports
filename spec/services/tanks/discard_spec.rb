# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tanks::Discard do
  let(:truck) { Truck.create!(plate_number: "H-#{SecureRandom.hex(2)}") }
  let(:tank)  { Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(2)}", capacity: 30_000) }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }

  it "discards a tank with no trips" do
    described_class.call(tank)
    expect(tank.reload.discarded?).to be true
  end

  it "raises HasDependents when kept trips reference the tank" do
    Trip.create!(truck: truck, tank: tank, route: route)
    expect { described_class.call(tank) }
      .to raise_error(ApplicationService::HasDependents)
  end

  it "cascades to kept documents" do
    document = Document.create!(documentable: tank, title: "Hydro test")
    described_class.call(tank)
    expect(document.reload.discarded?).to be true
  end

  describe "the returned result" do
    let(:result) { described_class.call(tank) }

    it "is a Tanks::Discard::Result" do
      expect(result).to be_a(Tanks::Discard::Result)
    end

    it "is successful" do
      expect(result.success).to be true
    end

    it "carries a success message" do
      expect(result.message).to eq("Tank has been successfully deleted.")
    end
  end
end
