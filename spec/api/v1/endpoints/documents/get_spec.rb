# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Documents::Get do
  subject(:do_request) { get "/api/v1/documents/#{document_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:document)     { Document.create!(documentable: truck, number: "INS-1", title: "Insurance") }
  let(:document_id)  { document.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept document" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the document id" do
        expect(response.parsed_body["id"]).to eq(document.id)
      end

      it "returns the title" do
        expect(response.parsed_body["title"]).to eq("Insurance")
      end
    end

    context "for a discarded document" do
      before do
        document.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Document not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Document not found.")
      end
    end

    context "for a non-existent id" do
      let(:document_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
