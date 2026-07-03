# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::Update do
  subject(:do_request) do
    patch "/api/v1/trucks/#{truck_id}/update", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {make: "Scania"} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
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
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept truck" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the truck" do
        expect(truck.reload.make).to eq("Scania")
      end

      it "returns the updated make" do
        expect(response.parsed_body["make"]).to eq("Scania")
      end
    end

    context "with a driver_id" do
      let(:driver) { Employee.create!(first_name: "Ibra", last_name: "Bah") }
      let(:params) { {driver_id: driver.id} }

      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the nested driver" do
        expect(response.parsed_body.dig("driver", "id")).to eq(driver.id)
      end
    end

    context "with nested tank attributes" do
      let!(:tank) do
        Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity: 30_000)
      end
      let(:params) { {make: "Scania", tank: {capacity: 45_000}} }

      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the truck" do
        expect(truck.reload.make).to eq("Scania")
      end

      it "updates the tank" do
        expect(tank.reload.capacity).to eq(45_000)
      end

      it "returns the updated tank" do
        expect(response.parsed_body.dig("tank", "capacity")).to eq(45_000)
      end
    end

    context "with an invalid nested tank" do
      let!(:tank) do
        Tank.create!(truck: truck, plate_number: "TK-#{SecureRandom.hex(3)}", capacity: 30_000)
      end
      let(:params) { {make: "Scania", tank: {capacity: -5}} }

      it "returns 422" do
        do_request
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "rolls back the truck change" do
        expect { do_request }.not_to change { truck.reload.make }
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

    context "with an out-of-range year" do
      let(:params) { {year: 1800} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with an invalid status value" do
      let(:params) { {status: "wrecked"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
