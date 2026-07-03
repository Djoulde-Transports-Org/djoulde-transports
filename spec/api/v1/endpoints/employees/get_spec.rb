# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Employees::Get do
  subject(:do_request) { get "/api/v1/employees/#{employee_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:employee)     { Employee.create!(first_name: "Mamadou", last_name: "Diallo", role: :driver) }
  let(:employee_id)  { employee.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept employee" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the employee id" do
        expect(response.parsed_body["id"]).to eq(employee.id)
      end

      it "returns first_name and last_name", :aggregate_failures do
        expect(response.parsed_body["first_name"]).to eq("Mamadou")
        expect(response.parsed_body["last_name"]).to eq("Diallo")
      end

      it "returns the role" do
        expect(response.parsed_body["role"]).to eq("driver")
      end
    end

    context "for a discarded employee" do
      before do
        employee.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Employee not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Employee not found.")
      end
    end

    context "for a non-existent id" do
      let(:employee_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Employee not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Employee not found.")
      end
    end
  end
end
