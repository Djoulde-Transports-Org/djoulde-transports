# frozen_string_literal: true

RSpec.describe "Admin trips", type: :request do
  include_context "with signed-in admin"
  let(:model) { Trip }
  let(:record) { build_trip }
  let(:create_params) do
    truck = build_truck
    {trip: {truck_id: truck.id, tank_id: build_tank(truck: truck).id,
            route_id: build_route.id, status: "scheduled"}}
  end
  let(:update_params) { {trip: {status: "completed"}} }

  it_behaves_like "a discardable admin resource", path: "trips"

  it "applies the update" do
    record
    patch "/admin/trips/#{record.id}", params: update_params
    expect(record.reload.status).to eq("completed")
  end

  it "shows origin, destination, quantities and the delivery note on the index", :aggregate_failures do
    note = build_delivery_note
    get "/admin/trips", headers: html
    expect(response.body).to include("Conakry", "Labe", "10000", "5000")
    expect(response.body).to include(admin_delivery_note_path(note))
  end

  it "shows the same details on the show page", :aggregate_failures do
    note = build_delivery_note
    get "/admin/trips/#{note.trip.id}", headers: html
    expect(response.body).to include("Conakry", "Labe", "10000", "5000", note.number)
  end
end
