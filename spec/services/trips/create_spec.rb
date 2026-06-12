# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trips::Create do
  let(:truck) { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}", capacity: 1_500) }
  let(:route) { Route.create!(origin: "A", destination: "B", rate: 1000) }
  let(:trip_params) { {truck_id: truck.id, route_id: route.id} }
  let(:delivery_note_params) do
    {number: "DN-#{SecureRandom.hex(2)}", gasoline_quantity: 1_000, diesel_quantity: 500}
  end

  it "creates the trip" do
    expect { described_class.call(trip_params, delivery_note_params) }
      .to change { Trip.count }.by(1)
  end

  it "creates the delivery note on the trip" do
    trip = described_class.call(trip_params, delivery_note_params)
    expect(trip.delivery_note.number).to eq(delivery_note_params[:number])
  end

  it "rolls back the trip when the delivery note is invalid" do
    expect do
      described_class.call(trip_params, {number: "DN-X"})
    rescue ActiveRecord::RecordInvalid
      nil
    end.not_to change { Trip.count }
  end

  it "rejects a load that does not fill the tank" do
    params = delivery_note_params.merge(diesel_quantity: 100)
    expect { described_class.call(trip_params, params) }
      .to raise_error(ActiveRecord::RecordInvalid, /less than the tank capacity/)
  end
end
