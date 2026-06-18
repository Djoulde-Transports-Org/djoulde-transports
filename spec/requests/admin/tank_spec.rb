# frozen_string_literal: true

RSpec.describe "Admin tanks", type: :request do
  include_context "signed-in admin"
  let(:model) { Tank }
  let(:record) { build_tank }
  let(:create_params) do
    {tank: {truck_id: build_truck.id, plate_number: "TNK-#{SecureRandom.hex(3)}",
            capacity: 25_000, year: 2021, status: "active"}}
  end
  let(:update_params) { {tank: {capacity: 40_000}} }

  it_behaves_like "a discardable admin resource", path: "tanks"

  it "applies the update" do
    record
    patch "/admin/tanks/#{record.id}", params: update_params
    expect(record.reload.capacity).to eq(40_000)
  end
end
