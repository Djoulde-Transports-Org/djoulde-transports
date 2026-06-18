# frozen_string_literal: true

RSpec.describe "Admin billing line items", type: :request do
  include_context "with signed-in admin"
  let(:model) { BillingLineItem }
  let(:record) { build_billing_line_item }
  let(:create_params) do
    {billing_line_item: {billing_statement_id: build_billing_statement.id, trip_id: build_trip.id,
                         amount: 500, tva: 90, rate: 250, gasoline_quantity: 0, diesel_quantity: 0}}
  end
  let(:update_params) { {billing_line_item: {amount: 750}} }

  it_behaves_like "a discardable admin resource", path: "billing_line_items"

  it "applies the update" do
    record
    patch "/admin/billing_line_items/#{record.id}", params: update_params
    expect(record.reload.amount).to eq(750)
  end
end
