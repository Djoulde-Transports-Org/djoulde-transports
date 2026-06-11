# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Routes::Create do
  subject(:do_request) do
    post "/api/v1/routes/create", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:params)       { {origin: "Kankan", destination: "Nzerekore", rate: 1160.59} }

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

    it "returns the forbidden error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    it "creates a route" do
      expect { do_request }.to change { Route.count }.by(1)
    end

    context "when the request is successful" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the route origin" do
        expect(response.parsed_body["origin"]).to eq(params[:origin])
      end

      it "returns the route rate with its decimal part" do
        expect(response.parsed_body["rate"]).to eq(1160.59)
      end
    end

    context "with missing required params" do
      let(:params) { {origin: "Kankan"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "with a negative rate" do
      let(:params) { super().merge(rate: -5) }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a duplicate origin + destination" do
      let!(:existing) do
        Route.create!(origin: params[:origin], destination: params[:destination], rate: 999)
      end

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
