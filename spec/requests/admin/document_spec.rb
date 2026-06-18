# frozen_string_literal: true

RSpec.describe "Admin documents", type: :request do
  include_context "signed-in admin"
  let(:model) { Document }
  let(:record) { build_document }
  let(:create_params) do
    truck = build_truck
    {document: {documentable_type: "Truck", documentable_id: truck.id, doc_type: "other",
                number: "DOC-#{SecureRandom.hex(3)}", title: "Insurance"}}
  end
  let(:update_params) { {document: {title: "Renewed"}} }

  it_behaves_like "a discardable admin resource", path: "documents"

  it "stamps uploaded_by with the acting admin on create" do
    post "/admin/documents", params: create_params
    expect(Document.order(:id).last.uploaded_by).to eq(admin)
  end

  it "applies the update" do
    record
    patch "/admin/documents/#{record.id}", params: update_params
    expect(record.reload.title).to eq("Renewed")
  end
end
