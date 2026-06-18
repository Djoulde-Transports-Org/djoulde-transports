# frozen_string_literal: true

RSpec.describe "Admin delivery notes", type: :request do
  include_context "with signed-in admin"
  let(:model) { DeliveryNote }
  let(:record) { build_delivery_note }
  let(:create_params) do
    {delivery_note: {trip_id: build_trip.id, number: "DN-#{SecureRandom.hex(3)}",
                     gasoline_quantity: 100, diesel_quantity: 50, missing_quantity: 0}}
  end
  let(:update_params) { {delivery_note: {missing_quantity: 7}} }

  it_behaves_like "a discardable admin resource", path: "delivery_notes"

  it "applies the update" do
    record
    patch "/admin/delivery_notes/#{record.id}", params: update_params
    expect(record.reload.missing_quantity).to eq(7)
  end
end
