# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Routes::Origins do
  subject(:do_request) { get "/api/v1/routes/origins", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      Route.create!(origin: "Conakry", destination: "Labe", rate: 1500)
      Route.create!(origin: "Conakry", destination: "Mamou", rate: 1800)
      Route.create!(origin: "Kankan", destination: "Siguiri", rate: 900)
      do_request
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns each distinct origin once" do
      expect(response.parsed_body).to contain_exactly("Conakry", "Kankan")
    end

    it "orders origins alphabetically" do
      expect(response.parsed_body).to eq([ "Conakry", "Kankan" ])
    end
  end

  context "when a route is discarded" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:route)  { Route.create!(origin: "Nzerekore", destination: "Lola", rate: 700) }

    before do
      route.discard
      do_request
    end

    it "excludes the discarded route's origin" do
      expect(response.parsed_body).not_to include("Nzerekore")
    end
  end

  context "when no routes exist" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns an empty array" do
      expect(response.parsed_body).to eq([])
    end
  end
end
