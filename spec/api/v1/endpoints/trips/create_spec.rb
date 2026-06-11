# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trips::Create do
  subject(:do_request) do
    post "/api/v1/trips/create", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}", capacity: 1_500) }
  let(:route)        { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }
  let(:delivery_note) { {number: "DN-#{SecureRandom.hex(2)}", gasoline_quantity: 1_000, diesel_quantity: 500} }
  let(:params) do
    {truck_id: truck.id, route_id: route.id, status: "scheduled", delivery_note: delivery_note}
  end

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

    it "creates a trip" do
      expect { do_request }.to change { Trip.count }.by(1)
    end

    it "creates the delivery note alongside the trip" do
      expect { do_request }.to change { DeliveryNote.count }.by(1)
    end

    context "when the request is successful" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the trip truck_id" do
        expect(response.parsed_body["truck_id"]).to eq(truck.id)
      end

      it "defaults the tank from the truck" do
        expect(response.parsed_body["tank_id"]).to eq(truck.tank.id)
      end

      it "nests the delivery note in the response" do
        expect(response.parsed_body.dig("delivery_note", "number")).to eq(delivery_note[:number])
      end

      it "defaults the note's missing quantity to 0" do
        expect(response.parsed_body.dig("delivery_note", "missing_quantity")).to eq(0)
      end
    end

    context "without a delivery note" do
      let(:params) { {truck_id: truck.id, route_id: route.id} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "when the delivery note has no product quantity" do
      let(:delivery_note) { {number: "DN-#{SecureRandom.hex(2)}"} }

      it "returns 422" do
        do_request
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create the trip" do
        expect { do_request }.not_to change { Trip.count }
      end
    end

    context "when the loaded quantity is less than the tank capacity" do
      let(:delivery_note) { {number: "DN-#{SecureRandom.hex(2)}", gasoline_quantity: 1_000, diesel_quantity: 100} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns a message that the load is below capacity" do
        expect(response.parsed_body.dig("error", "details", "base").join)
          .to include('is less than the tank capacity (1500 L)')
      end

      it "does not create the trip" do
        expect { do_request }.not_to change { Trip.count }
      end
    end

    context "when the loaded quantity exceeds the tank capacity" do
      let(:delivery_note) { {number: "DN-#{SecureRandom.hex(2)}", gasoline_quantity: 1_000, diesel_quantity: 800} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns a message that the load exceeds capacity" do
        expect(response.parsed_body.dig("error", "details", "base").join)
          .to include('exceeds the tank capacity (1500 L)')
      end
    end

    context "with missing required params" do
      let(:params) { {truck_id: truck.id} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "with an invalid status value" do
      let(:params) { super().merge(status: "nope") }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
