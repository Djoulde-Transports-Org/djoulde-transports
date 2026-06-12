# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Maintenances::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/maintenances#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let!(:maintenance) { Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :routine) }

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

    it "returns kept maintenances" do
      expect(response.parsed_body.pluck("id")).to include(maintenance.id)
    end

    it "sets pagination headers", :aggregate_failures do
      expect(response.headers["Total"]).to eq("1")
      expect(response.headers["Per-Page"]).to eq("25")
    end
  end

  context "when a maintenance is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      maintenance.discard
      do_request
    end

    it "excludes discarded maintenances" do
      expect(response.parsed_body.pluck("id")).not_to include(maintenance.id)
    end
  end

  context "when filtering by truck_id" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {truck_id: truck.id} }
    let!(:other_maintenance) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-other"), performed_on: Time.zone.today)
    end

    before { do_request }

    it "returns only maintenances for that truck" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(maintenance.id)
    end
  end

  context "when filtering by kind" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {kind: "repair"} }
    let!(:repair) do
      Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :repair)
    end

    before { do_request }

    it "returns only maintenances with that kind" do
      expect(response.parsed_body.pluck("id")).to contain_exactly(repair.id)
    end
  end

  context "when kind is not a valid value" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {kind: "nope"} }

    before { do_request }

    it "returns 422" do
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
