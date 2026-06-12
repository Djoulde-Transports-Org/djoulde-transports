# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Documents::Update do
  subject(:do_request) do
    patch "/api/v1/documents/#{document_id}/update", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {title: "Renamed"} }
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
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept document" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the title" do
        expect(document.reload.title).to eq("Renamed")
      end

      it "returns the updated title" do
        expect(response.parsed_body["title"]).to eq("Renamed")
      end
    end

    context "when expires_on precedes issued_on" do
      let(:params) { {issued_on: "2026-06-01", expires_on: "2026-05-01"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
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
