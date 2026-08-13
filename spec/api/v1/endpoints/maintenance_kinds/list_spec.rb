# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::MaintenanceKinds::List do
  subject(:do_request) { get "/api/v1/maintenance_kinds", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let!(:repair)      { MaintenanceKind.create!(name: "repair") }
  let!(:routine)     { MaintenanceKind.create!(name: "routine") }

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

    it "returns the kinds ordered by name" do
      expect(response.parsed_body.pluck("name")).to eq([ "repair", "routine" ])
    end
  end

  context "when a kind is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      repair.discard
      do_request
    end

    it "excludes discarded kinds" do
      expect(response.parsed_body.pluck("id")).not_to include(repair.id)
    end
  end
end
