# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::List do
  subject(:do_request) { get "/api/v1/trucks", headers: headers }

  let(:headers)      { {} }
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
end
