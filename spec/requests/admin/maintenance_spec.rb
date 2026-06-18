# frozen_string_literal: true

RSpec.describe "Admin maintenances", type: :request do
  include_context "signed-in admin"
  let(:model) { Maintenance }
  let(:record) { build_maintenance }
  let(:create_params) do
    {maintenance: {truck_id: build_truck.id, kind: "routine", state: "started", performed_on: "2026-01-05"}}
  end
  let(:update_params) { {maintenance: {state: "completed"}} }

  it_behaves_like "a discardable admin resource", path: "maintenances"

  it "applies the update" do
    record
    patch "/admin/maintenances/#{record.id}", params: update_params
    expect(record.reload.state).to eq("completed")
  end
end
