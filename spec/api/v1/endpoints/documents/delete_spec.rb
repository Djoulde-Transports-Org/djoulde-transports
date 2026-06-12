# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Documents::Delete do
  subject(:do_request) { delete "/api/v1/documents/#{document_id}/delete", headers: headers }

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
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

  context "when the user is not an admin" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end

    it "returns the forbidden error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept document" do
      it "discards the document" do
        do_request
        expect(document.reload.discarded?).to be true
      end

      it "returns 200" do
        do_request
        expect(response).to have_http_status(:ok)
      end

      it "returns the success message" do
        do_request
        expect(response.parsed_body["success"]).to be true
      end
    end

    context "with a discarded document" do
      before do
        document.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a non-existent id" do
      let(:document_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
