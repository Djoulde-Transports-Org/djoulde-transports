# frozen_string_literal: true

RSpec.describe "Admin billing statements", type: :request do
  include_context "with signed-in admin"
  let(:model) { BillingStatement }
  let(:record) { build_billing_statement }
  let(:create_params) do
    {billing_statement: {number: "BS-#{SecureRandom.hex(3)}", month: "2026-03-01", status: "draft"}}
  end
  let(:update_params) { {billing_statement: {status: "issued"}} }

  it_behaves_like "a discardable admin resource", path: "billing_statements"

  it "applies the update" do
    record
    patch "/admin/billing_statements/#{record.id}", params: update_params
    expect(record.reload.status).to eq("issued")
  end
end
