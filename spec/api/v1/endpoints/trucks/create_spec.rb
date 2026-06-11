# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::Create do
  subject(:do_request) do
    post "/api/v1/trucks", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:params) do
    {
      plate_number: "NEW-#{SecureRandom.hex(2)}",
      vin:          "VIN-#{SecureRandom.hex(4)}",
      make:         "Volvo",
      model:        "FH",
      year:         2022,
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

    it "creates a truck" do
      expect { do_request }.to change { Truck.count }.by(1)
    end

    context "when the request is successful" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the truck's plate_number" do
        expect(response.parsed_body["plate_number"]).to eq(params[:plate_number])
      end

      it "stamps created_by to the current user" do
        expect(response.parsed_body["created_by_id"]).to eq(admin.id)
      end
    end

    context "with missing required params" do
      let(:params) { {plate_number: ""} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "with a duplicate plate_number" do
      let!(:existing) do
        Truck.create!(plate_number: params[:plate_number], make: "X", model: "Y", year: 2020)
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
