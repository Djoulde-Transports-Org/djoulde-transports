# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routes::Discard do
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:truck) { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }

  it "discards the route with no trips" do
    described_class.call(route)
    expect(route.reload.discarded?).to be true
  end

  it "raises HasDependents when kept trips reference the route" do
    Trip.create!(truck: truck, route: route)
    expect { described_class.call(route) }
      .to raise_error(ApplicationService::HasDependents)
  end
end
