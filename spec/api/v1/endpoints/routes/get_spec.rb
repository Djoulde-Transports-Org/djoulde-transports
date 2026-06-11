# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Routes::Get do
  subject(:do_request) { get "/api/v1/routes/#{route_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:route)        { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }
  let(:route_id)     { route.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept route" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the route id" do
        expect(response.parsed_body["id"]).to eq(route.id)
      end

      it "returns the route origin" do
        expect(response.parsed_body["origin"]).to eq(route.origin)
      end
    end

    context "for a discarded route" do
      before do
        route.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Route not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Route not found.")
      end
    end

    context "for a non-existent id" do
      let(:route_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
