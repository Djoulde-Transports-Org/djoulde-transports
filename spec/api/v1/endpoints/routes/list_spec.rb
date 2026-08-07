# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Routes::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/routes#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let!(:route) { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }

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

    it "returns kept routes" do
      expect(response.parsed_body.pluck("id")).to include(route.id)
    end

    it "sets pagination headers", :aggregate_failures do
      expect(response.headers["Total"]).to eq("1")
      expect(response.headers["Per-Page"]).to eq("25")
    end
  end

  context "when a route is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      route.discard
      do_request
    end

    it "excludes discarded routes" do
      expect(response.parsed_body.pluck("id")).not_to include(route.id)
    end
  end

  context "with pagination params" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:extra_routes) do
      Array.new(4) do |i|
        Route.create!(origin: "Kankan", destination: "Stop-#{i}", rate: 2000 + i)
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

  context "with an origin filter" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:other_route) { Route.create!(origin: "Kankan", destination: "Siguiri", rate: 900) }
    let(:params) { {origin: "Conakry"} }

    before { do_request }

    it "returns only routes with that exact origin" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(route.id)
    end

    it "excludes routes with a different origin" do
      expect(response.parsed_body.pluck("id")).not_to include(other_route.id)
    end
  end

  context "with an origin filter that matches nothing" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {origin: "Nzerekore"} }

    before { do_request }

    it "returns an empty array" do
      expect(response.parsed_body).to eq([])
    end
  end
end
