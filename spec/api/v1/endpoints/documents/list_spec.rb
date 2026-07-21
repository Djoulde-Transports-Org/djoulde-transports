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
  let!(:document)    { Document.create!(documentable: truck, number: "INS-1", title: "Insurance", doc_type: :truck_insurance) }

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

    it "returns kept documents in the items array" do
      expect(response.parsed_body["items"].pluck("id")).to include(document.id)
    end

    it "includes has_more in the response" do
      expect(response.parsed_body).to have_key("has_more")
    end

    it "includes next_cursor in the response" do
      expect(response.parsed_body).to have_key("next_cursor")
    end
  end

  context "when a document is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      document.discard
      do_request
    end

    it "excludes discarded documents" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(document.id)
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
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(document.id)
    end
  end

  context "when filtering by doc_type" do
    let(:headers)  { bearer_headers(viewer_token) }
    let(:params)   { {doc_type: "truck_registration"} }
    let!(:license) { Document.create!(documentable: truck, number: "LIC-1", title: "License", doc_type: :truck_registration) }

    before { do_request }

    it "returns only documents of that kind" do
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(license.id)
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

  context "when filtering by date_from" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {date_from: "2026-06-01"} }
    let!(:recent) do
      Document.create!(documentable: truck, number: "REC-1", title: "Recent", issued_on: Date.new(2026, 6, 15))
    end
    let!(:old) do
      Document.create!(documentable: truck, number: "OLD-1", title: "Old", issued_on: Date.new(2025, 12, 1))
    end

    before { do_request }

    it "includes documents with issued_on on or after date_from" do
      expect(response.parsed_body["items"].pluck("id")).to include(recent.id)
    end

    it "excludes documents with issued_on before date_from" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(old.id)
    end
  end

  context "when filtering by date_to" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {date_to: "2025-12-31"} }
    let!(:old) do
      Document.create!(documentable: truck, number: "OLD-2", title: "Old2", issued_on: Date.new(2025, 11, 1))
    end
    let!(:recent) do
      Document.create!(documentable: truck, number: "REC-2", title: "Recent2", issued_on: Date.new(2026, 3, 1))
    end

    before { do_request }

    it "includes documents with issued_on on or before date_to" do
      expect(response.parsed_body["items"].pluck("id")).to include(old.id)
    end

    it "excludes documents with issued_on after date_to" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(recent.id)
    end
  end

  context "when filtering by search" do
    let(:headers)   { bearer_headers(viewer_token) }
    let(:params)    { {search: "Reg"} }
    let!(:matched)  { Document.create!(documentable: truck, number: "REG-1", title: "Registration") }
    let!(:unmatched) { Document.create!(documentable: truck, number: "INV-1", title: "Invoice", doc_type: :invoice) }

    before { do_request }

    it "includes documents whose title starts with the search term" do
      expect(response.parsed_body["items"].pluck("id")).to include(matched.id)
    end

    it "excludes documents whose title does not match" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(unmatched.id)
    end
  end

  context "when paginating with a cursor" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      # document already exists; create 2 more so we have 3 total
      Document.create!(documentable: truck, number: "DOC-2", title: "Doc Two")
      Document.create!(documentable: truck, number: "DOC-3", title: "Doc Three")
    end

    context "with the first page and limit=2" do
      let(:params) { {limit: 2} }

      before { do_request }

      it "returns 2 items" do
        expect(response.parsed_body["items"].size).to eq(2)
      end

      it "sets has_more to true" do
        expect(response.parsed_body["has_more"]).to be true
      end

      it "returns a next_cursor" do
        expect(response.parsed_body["next_cursor"]).to be_present
      end
    end

    context "with the second page using the cursor from the first page" do
      before do
        get "/api/v1/documents?limit=2", headers: headers
        cursor = response.parsed_body["next_cursor"]
        get "/api/v1/documents?limit=2&after=#{cursor}", headers: headers
      end

      it "returns the remaining item" do
        expect(response.parsed_body["items"].size).to eq(1)
      end

      it "sets has_more to false" do
        expect(response.parsed_body["has_more"]).to be false
      end

      it "returns nil next_cursor" do
        expect(response.parsed_body["next_cursor"]).to be_nil
      end
    end

    context "when limit is out of range" do
      let(:params) { {limit: 200} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
