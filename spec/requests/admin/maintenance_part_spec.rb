# frozen_string_literal: true

RSpec.describe "Admin maintenance parts", type: :request do
  include_context "signed-in admin"
  let(:model) { MaintenancePart }
  let(:record) { build_maintenance_part }
  let(:create_params) do
    {maintenance_part: {maintenance_id: build_maintenance.id, name: "Brake pad", price: 80}}
  end
  let(:update_params) { {maintenance_part: {price: 120}} }

  it_behaves_like "a discardable admin resource", path: "maintenance_parts"

  it "applies the update" do
    record
    patch "/admin/maintenance_parts/#{record.id}", params: update_params
    expect(record.reload.price).to eq(120)
  end
end
