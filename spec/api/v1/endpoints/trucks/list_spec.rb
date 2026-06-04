# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/trucks#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let!(:truck) do
    Truck.create!(plate_number: "AB-#{SecureRandom.hex(3)}", make: "Volvo", model: "FH", year: 2020)
  end

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

    it "returns kept trucks" do
      expect(response.parsed_body.pluck("id")).to include(truck.id)
    end

    it "sets pagination headers", :aggregate_failures do
      expect(response.headers["Total"]).to eq("1")
      expect(response.headers["Per-Page"]).to eq("25")
    end
  end

  context "when a truck is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      truck.discard
      do_request
    end

    it "excludes discarded trucks" do
      expect(response.parsed_body.pluck("id")).not_to include(truck.id)
    end
  end

  context "with pagination params" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:extra_trucks) do
      Array.new(4) do |i|
        Truck.create!(plate_number: "PG-#{SecureRandom.hex(3)}", make: "Volvo", model: "FH", year: 2020 + i)
      end
    end

    context "on page 1 with per_page=2" do
      let(:params) { {page: 1, per_page: 2} }

      before { do_request }

      it "returns 2 records" do
        expect(response.parsed_body.size).to eq(2)
      end

      it "reports total + per-page in headers" do
        expect(response.headers["Total"]).to eq("5")
        expect(response.headers["Per-Page"]).to eq("2")
      end

      it "exposes a Link header with next/last" do
        expect(response.headers["Link"]).to include('rel="next"')
        expect(response.headers["Link"]).to include('rel="last"')
      end
    end

    context "on the last page" do
      let(:params) { {page: 3, per_page: 2} }

      before { do_request }

      it "returns the remaining record" do
        expect(response.parsed_body.size).to eq(1)
      end
    end

    context "past the last page" do
      let(:params) { {page: 99, per_page: 2} }

      before { do_request }

      it "returns an empty array" do
        expect(response.parsed_body).to eq([])
      end
    end
  end

  context "when per_page exceeds the configured max" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {per_page: 101} }

    before { do_request }

    it "caps per_page at 100" do
      expect(response.headers["Per-Page"]).to eq("100")
    end
  end
end
