# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Tanks::Create do
  subject(:do_request) do
    post "/api/v1/tanks/create", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) { Truck.create!(plate_number: "H-#{SecureRandom.hex(3)}") }
  let(:params) do
    {
      truck_id:        truck.id,
      plate_number:    "TK-#{SecureRandom.hex(2)}",
      capacity: 28_000,
    }
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

    it "creates a tank" do
      expect { do_request }.to change { Tank.count }.by(1)
    end

    context "when the request is successful" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the tank's plate_number" do
        expect(response.parsed_body["plate_number"]).to eq(params[:plate_number])
      end

      it "attaches the tank to the truck" do
        expect(response.parsed_body["truck_id"]).to eq(truck.id)
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

    context "with a second tank on the same truck" do
      let!(:existing) do
        Tank.create!(truck: truck, plate_number: "TK-FIRST", capacity: 20_000)
      end

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a duplicate plate_number" do
      let!(:existing) do
        other_truck = Truck.create!(plate_number: "H-#{SecureRandom.hex(3)}")
        Tank.create!(truck: other_truck, plate_number: params[:plate_number], capacity: 20_000)
      end

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with an out-of-range year" do
      let(:params) { super().merge(year: 1800) }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with an invalid status value" do
      let(:params) { super().merge(status: "wrecked") }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
