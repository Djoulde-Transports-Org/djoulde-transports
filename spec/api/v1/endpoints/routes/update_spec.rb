# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Routes::Update do
  subject(:do_request) do
    patch "/api/v1/routes/#{route_id}/update", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {rate: 1800} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
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

  context "when the user is not an admin" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept route" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the route" do
        expect(route.reload.rate).to eq(1800)
      end

      it "returns the updated rate" do
        expect(response.parsed_body["rate"]).to eq(1800)
      end
    end

    context "with a discarded route" do
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

    context "with a non-existent id" do
      let(:route_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a negative rate" do
      let(:params) { {rate: -5} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
