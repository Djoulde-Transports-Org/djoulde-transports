# frozen_string_literal: true

# Small factories so spec call sites don't have to set up the (truck, tank)
# pair every time they want a trip.
module FleetHelpers
  def build_truck_with_tank(plate: nil, capacity: 30_000)
    plate ||= "T-#{SecureRandom.hex(3)}"
    truck  = Truck.create!(plate_number: plate)
    Tank.create!(
      truck: truck,
      plate_number: "TK-#{SecureRandom.hex(3)}",
      capacity: capacity
    )
    truck
  end
end

RSpec.configure do |config|
  config.include FleetHelpers
end
