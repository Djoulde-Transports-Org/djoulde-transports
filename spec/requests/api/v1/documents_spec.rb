# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/api/v1/documents", type: :request do
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  let(:truck) { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }

  describe "POST /api/v1/documents" do
    it "creates a polymorphic document" do
      expect {
        post "/api/v1/documents",
          params: {
            documentable_type: "Truck",
            documentable_id: truck.id,
            title: "Insurance 2026",
            doc_type: "insurance",
          },
          headers: bearer_headers(admin_token)
      }.to change { Document.count }.by(1)
    end

    it "rejects unknown documentable_type" do
      post "/api/v1/documents",
        params: {documentable_type: "Spaceship", documentable_id: 1, title: "x"},
        headers: bearer_headers(admin_token)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /api/v1/documents" do
    it "filters by documentable_type and documentable_id" do
      Document.create!(documentable: truck, title: "T1")
      Document.create!(documentable: truck, title: "T2")
      get "/api/v1/documents",
        params: {documentable_type: "Truck", documentable_id: truck.id},
        headers: bearer_headers(viewer_token)
      expect(response.parsed_body.length).to eq(2)
    end
  end

  describe "DELETE /api/v1/documents/:id" do
    it "discards the document" do
      document = Document.create!(documentable: truck, title: "Insurance")
      delete "/api/v1/documents/#{document.id}", headers: bearer_headers(admin_token)
      expect(document.reload.discarded?).to be true
    end
  end
end
