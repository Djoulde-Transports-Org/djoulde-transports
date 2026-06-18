# frozen_string_literal: true

RSpec.describe "Admin routes", type: :request do
  include_context "with signed-in admin"
  let(:model) { Route }
  let(:record) { build_route }
  let(:create_params) { {route: {origin: "Mamou", destination: "Kankan", rate: 300}} }
  let(:update_params) { {route: {rate: 999}} }

  it_behaves_like "a discardable admin resource", path: "routes"

  it "applies the update" do
    record
    patch "/admin/routes/#{record.id}", params: update_params
    expect(record.reload.rate).to eq(999)
  end
end
