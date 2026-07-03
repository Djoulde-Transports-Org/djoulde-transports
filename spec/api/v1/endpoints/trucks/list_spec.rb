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
    Truck.create!(plate_number: "GN-#{SecureRandom.hex(3).upcase}", make: "Volvo", model: "FH", year: 2020)
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

    it "returns an array" do
      expect(response.parsed_body).to be_an(Array)
    end

    it "returns kept trucks" do
      expect(response.parsed_body.pluck("id")).to include(truck.id)
    end
  end

  context "with pagination" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:extra_trucks) do
      Array.new(4) do
        Truck.create!(plate_number: "GN-#{SecureRandom.hex(3).upcase}", make: "Mercedes", model: "Actros", year: 2021)
      end
    end

    context "with pagination on page 1 with per_page=2" do
      let(:params) { {page: 1, per_page: 2} }

      before { do_request }

      it "returns 2 records" do
        expect(response.parsed_body.size).to eq(2)
      end

      it "sets Total and Per-Page headers", :aggregate_failures do
        expect(response.headers["Total"]).to eq("5")
        expect(response.headers["Per-Page"]).to eq("2")
      end

      it "sets a Link header with next and last", :aggregate_failures do
        expect(response.headers["Link"]).to include('rel="next"')
        expect(response.headers["Link"]).to include('rel="last"')
      end
    end

    context "when per_page exceeds the configured max" do
      let(:params) { {per_page: 101} }

      before { do_request }

      it "caps per_page at 100" do
        expect(response.headers["Per-Page"]).to eq("100")
      end
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

  context "with a status filter" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:ready_truck) do
      Truck.create!(plate_number: "RD-#{SecureRandom.hex(3).upcase}", make: "Volvo", model: "FH", year: 2020,
                   status: :ready)
    end
    let!(:maintenance_truck) do
      Truck.create!(plate_number: "MT-#{SecureRandom.hex(3).upcase}", make: "Volvo", model: "FH", year: 2020,
                   status: :in_maintenance)
    end

    context "when filtering by ready" do
      let(:params) { {status: "ready"} }

      before { do_request }

      it "returns only ready trucks", :aggregate_failures do
        ids = response.parsed_body.pluck("id")
        expect(ids).to include(ready_truck.id)
        expect(ids).not_to include(maintenance_truck.id)
      end
    end

    context "when filtering by in_maintenance" do
      let(:params) { {status: "in_maintenance"} }

      before { do_request }

      it "returns only in_maintenance trucks", :aggregate_failures do
        ids = response.parsed_body.pluck("id")
        expect(ids).to include(maintenance_truck.id)
        expect(ids).not_to include(ready_truck.id)
      end
    end

    context "with an invalid status value" do
      let(:params) { {status: "flying"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  context "with a search filter" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:target_truck) do
      Truck.create!(plate_number: "AA-FFFF", make: "Volvo", model: "FH", year: 2020)
    end
    let!(:other_truck) do
      Truck.create!(plate_number: "BB-ZZZZ", make: "Volvo", model: "FH", year: 2020)
    end

    context "when searching by exact prefix" do
      let(:params) { {search: "AA-"} }

      before { do_request }

      it "returns the matching truck" do
        expect(response.parsed_body.pluck("id")).to include(target_truck.id)
      end

      it "excludes non-matching trucks" do
        expect(response.parsed_body.pluck("id")).not_to include(other_truck.id)
      end
    end

    context "when searching case-insensitively" do
      let(:params) { {search: "aa-"} }

      before { do_request }

      it "returns the matching truck regardless of case" do
        expect(response.parsed_body.pluck("id")).to include(target_truck.id)
      end
    end

    context "with a search that matches nothing" do
      let(:params) { {search: "ZZ-XXXX"} }

      before { do_request }

      it "returns an empty array" do
        expect(response.parsed_body).to eq([])
      end
    end
  end
end
