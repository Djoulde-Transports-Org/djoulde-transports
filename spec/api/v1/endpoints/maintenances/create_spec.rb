# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Maintenances::Create do
  subject(:do_request) do
    post "/api/v1/maintenances/create", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:params) do
    {truck_id: truck.id, performed_on: Time.zone.today.to_s, kind: "repair", estimated_duration: 3.0,
     parts: [ {name: "brake pads", price: 1100}, {name: "oil filter", price: 800} ]}
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

    it "creates a maintenance record" do
      expect { do_request }.to change { Maintenance.count }.by(1)
    end

    context "when the request is successful" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the maintenance kind" do
        expect(response.parsed_body["kind"]).to eq("repair")
      end

      it "returns the total cost as the sum of the part prices" do
        expect(response.parsed_body["cost"]).to eq(1900)
      end

      it "returns the estimated duration" do
        expect(response.parsed_body["estimated_duration"].to_f).to eq(3.0)
      end

      it "defaults the state to started" do
        expect(response.parsed_body["state"]).to eq("started")
      end

      it "has no actual duration yet" do
        expect(response.parsed_body["actual_duration"]).to be_nil
      end

      it "returns the parts that were changed" do
        expect(response.parsed_body["parts"].map { |p| [ p["name"], p["price"] ] })
          .to contain_exactly([ "brake pads", 1100 ], [ "oil filter", 800 ])
      end

      it "moves the truck into the in_maintenance status" do
        expect(truck.reload).to be_in_maintenance
      end
    end

    context "when parts is omitted" do
      let(:params) { {truck_id: truck.id, performed_on: Time.zone.today.to_s} }

      before { do_request }

      it "defaults parts to an empty array" do
        expect(response.parsed_body["parts"]).to eq([])
      end

      it "sets the cost to zero" do
        expect(response.parsed_body["cost"]).to eq(0)
      end
    end

    context "when a part is missing its name" do
      let(:params) do
        {truck_id: truck.id, performed_on: Time.zone.today.to_s, parts: [ {price: 100} ]}
      end

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when truck_id is missing" do
      let(:params) { {performed_on: Time.zone.today.to_s} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed error code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "when kind is not a valid value" do
      let(:params) { {truck_id: truck.id, performed_on: Time.zone.today.to_s, kind: "nope"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when estimated_duration is negative" do
      let(:params) { {truck_id: truck.id, performed_on: Time.zone.today.to_s, estimated_duration: -1} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
