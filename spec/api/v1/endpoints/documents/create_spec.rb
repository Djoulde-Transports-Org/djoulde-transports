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
     title: "Insurance 2026", doc_type: "truck_insurance"}
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

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "auto-generates a DT-<id> number" do
        document = Document.find(response.parsed_body["id"])
        expect(response.parsed_body["number"]).to eq("DT-#{document.id}")
      end
    end

    context "when the number is already taken" do
      before do
        Document.create!(documentable: truck, number: "INS-2026", title: "Existing")
        do_request
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when documentable_type is not allowed" do
      let(:params) { {documentable_type: "Spaceship", documentable_id: 1, title: "x"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when documentable_type is Tank" do
      let(:tank) { build_truck_with_tank(plate: "TK-#{SecureRandom.hex(2)}").tank }
      let(:params) do
        {documentable_type: "Tank", documentable_id: tank.id, number: "CONF-2026",
         title: "Certificat de baremage", doc_type: "conformity_certificate"}
      end

      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "attaches the document to the tank", :aggregate_failures do
        expect(response.parsed_body["documentable_type"]).to eq("Tank")
        expect(response.parsed_body["documentable_id"]).to eq(tank.id)
      end
    end

    context "when documentable_type is Employee" do
      let(:employee) { Employee.create!(first_name: "Mamadou", last_name: "Diallo") }
      let(:params) do
        {documentable_type: "Employee", documentable_id: employee.id, number: "LIC-2026",
         title: "Permis de conduire", doc_type: "driver_license"}
      end

      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "attaches the document to the employee", :aggregate_failures do
        expect(response.parsed_body["documentable_type"]).to eq("Employee")
        expect(response.parsed_body["documentable_id"]).to eq(employee.id)
      end
    end
  end
end
