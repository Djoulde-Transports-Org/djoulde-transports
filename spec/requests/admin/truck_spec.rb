# frozen_string_literal: true

RSpec.describe "Admin trucks", type: :request do
  include_context "signed-in admin"
  let(:model) { Truck }
  let(:record) { build_truck }
  let(:create_params) { {truck: {plate_number: "TRK-#{SecureRandom.hex(3)}", year: 2021, status: "ready"}} }
  let(:update_params) { {truck: {make: "Scania"}} }

  it_behaves_like "a discardable admin resource", path: "trucks"

  it "stamps created_by with the acting admin on create" do
    post "/admin/trucks", params: create_params
    expect(Truck.order(:id).last.created_by).to eq(admin)
  end

  it "links to the tank on the index" do
    tank = build_tank
    get "/admin/trucks", headers: html
    expect(response.body).to include(admin_tank_path(tank))
  end

  it "shows a Tank panel linking to the tank on show", :aggregate_failures do
    tank = build_tank
    get "/admin/trucks/#{tank.truck.id}", headers: html
    expect(response.body).to include("Tank", admin_tank_path(tank))
  end

  it "shows a placeholder when the truck has no tank" do
    get "/admin/trucks/#{record.id}", headers: html
    expect(response.body).to include("No tank assigned")
  end
end
