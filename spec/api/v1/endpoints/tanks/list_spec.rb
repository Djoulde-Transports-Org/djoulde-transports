# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Tanks::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/tanks#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) { Truck.create!(plate_number: "H-#{SecureRandom.hex(3)}") }
  let!(:tank) do
    Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity_liters: 30_000)
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

    it "returns kept tanks" do
      expect(response.parsed_body.pluck("id")).to include(tank.id)
    end

    it "sets pagination headers", :aggregate_failures do
      expect(response.headers["Total"]).to eq("1")
      expect(response.headers["Per-Page"]).to eq("25")
    end
  end

  context "when filtering by truck_id" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:other_tank) do
      other_truck = Truck.create!(plate_number: "H-#{SecureRandom.hex(3)}")
      Tank.create!(truck: other_truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity_liters: 25_000)
    end
    let(:params) { {truck_id: truck.id} }

    before { do_request }

    it "returns only tanks on that truck" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(tank.id)
    end
  end

  context "when a tank is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      tank.discard
      do_request
    end

    it "excludes discarded tanks" do
      expect(response.parsed_body.pluck("id")).not_to include(tank.id)
    end
  end

  context "with pagination params" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:extra_tanks) do
      Array.new(4) do
        extra_truck = Truck.create!(plate_number: "H-#{SecureRandom.hex(3)}")
        Tank.create!(truck: extra_truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity_liters: 22_000)
      end
    end

    context "when on page 1 with per_page=2" do
      let(:params) { {page: 1, per_page: 2} }

      before { do_request }

      it "returns 2 records" do
        expect(response.parsed_body.size).to eq(2)
      end

      it "reports total + per-page in headers", :aggregate_failures do
        expect(response.headers["Total"]).to eq("5")
        expect(response.headers["Per-Page"]).to eq("2")
      end

      it "exposes a Link header with next/last", :aggregate_failures do
        expect(response.headers["Link"]).to include('rel="next"')
        expect(response.headers["Link"]).to include('rel="last"')
      end
    end

    context "when past the last page" do
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
