# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::Delete do
  subject(:do_request) { delete "/api/v1/trucks/#{truck_id}/delete", headers: headers }

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) do
    Truck.create!(plate_number: "AB-#{SecureRandom.hex(3)}", make: "Volvo", model: "FH", year: 2020)
  end
  let(:truck_id) { truck.id }

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

    context "with a kept truck" do
      before do
        Current.user = admin
        do_request
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns success: true" do
        expect(response.parsed_body["success"]).to be true
      end

      it "returns the success message with the truck id" do
        expect(response.parsed_body["message"]).to eq("Truck has been successfully deleted.")
      end

      it "discards the truck" do
        expect(truck.reload).to be_discarded
      end

      it "stamps discarded_by on the truck" do
        expect(truck.reload.discarded_by_id).to eq(admin.id)
      end
    end

    context "with a discarded truck" do
      before do
        truck.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Truck not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Truck not found.")
      end
    end

    context "with a non-existent id" do
      let(:truck_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
