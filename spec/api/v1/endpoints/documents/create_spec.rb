# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Documents::Create do
  subject(:do_request) do
    post "/api/v1/documents/create", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:params) do
    {documentable_type: "Truck", documentable_id: truck.id, number: "INS-2026",
     title: "Insurance 2026", doc_type: "insurance"}
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

    it "creates a document" do
      expect { do_request }.to change { Document.count }.by(1)
    end

    context "when the request succeeds" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the title" do
        expect(response.parsed_body["title"]).to eq("Insurance 2026")
      end

      it "returns the number" do
        expect(response.parsed_body["number"]).to eq("INS-2026")
      end

      it "stamps uploaded_by to the current user" do
        expect(response.parsed_body["uploaded_by_id"]).to eq(admin.id)
      end
    end

    context "when title is missing" do
      let(:params) { {documentable_type: "Truck", documentable_id: truck.id, number: "X-1"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed error code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "when number is missing" do
      let(:params) { {documentable_type: "Truck", documentable_id: truck.id, title: "No number"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed error code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "when documentable_type is not allowed" do
      let(:params) { {documentable_type: "Spaceship", documentable_id: 1, title: "x"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
