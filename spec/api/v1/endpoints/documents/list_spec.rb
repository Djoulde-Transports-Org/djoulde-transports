# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Documents::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/documents#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let!(:document)    { Document.create!(documentable: truck, number: "INS-1", title: "Insurance", doc_type: :insurance) }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns kept documents" do
      expect(response.parsed_body.pluck("id")).to include(document.id)
    end

    it "sets pagination headers", :aggregate_failures do
      expect(response.headers["Total"]).to eq("1")
      expect(response.headers["Per-Page"]).to eq("25")
    end
  end

  context "when a document is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      document.discard
      do_request
    end

    it "excludes discarded documents" do
      expect(response.parsed_body.pluck("id")).not_to include(document.id)
    end
  end

  context "when filtering by documentable" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {documentable_type: "Truck", documentable_id: truck.id} }
    let!(:other) do
      Document.create!(documentable: Truck.create!(plate_number: "T-other"), number: "OTH-1", title: "Other")
    end

    before { do_request }

    it "returns only documents for that owner" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(document.id)
    end
  end

  context "when filtering by doc_type" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {doc_type: "license"} }
    let!(:license) { Document.create!(documentable: truck, number: "LIC-1", title: "License", doc_type: :license) }

    before { do_request }

    it "returns only documents of that kind" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(license.id)
    end
  end

  context "when documentable_type is not a valid value" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {documentable_type: "Spaceship"} }

    before { do_request }

    it "returns 422" do
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
