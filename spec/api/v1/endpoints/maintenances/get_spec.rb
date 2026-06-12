# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Maintenances::Get do
  subject(:do_request) { get "/api/v1/maintenances/#{maintenance_id}", headers: headers }

  let(:headers)        { {} }
  let(:viewer_setup)   { auth_setup(role: :driver_readonly) }
  let(:viewer_token)   { viewer_setup[1] }
  let(:truck)          { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance)    { Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :routine) }
  let(:maintenance_id) { maintenance.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept maintenance" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the maintenance id" do
        expect(response.parsed_body["id"]).to eq(maintenance.id)
      end

      it "returns the maintenance truck_id" do
        expect(response.parsed_body["truck_id"]).to eq(truck.id)
      end
    end

    context "for a discarded maintenance" do
      before do
        maintenance.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Maintenance not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Maintenance not found.")
      end
    end

    context "for a non-existent id" do
      let(:maintenance_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Maintenance not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Maintenance not found.")
      end
    end
  end
end
