# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Employees::Delete do
  subject(:do_request) { delete "/api/v1/employees/#{employee_id}/delete", headers: headers }

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:employee)    { Employee.create!(first_name: "Mamadou", last_name: "Diallo", role: :driver) }
  let(:employee_id) { employee.id }

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

    context "with a kept employee" do
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

      it "returns the success message" do
        expect(response.parsed_body["message"]).to eq("Employee has been successfully deleted.")
      end

      it "discards the employee" do
        expect(employee.reload).to be_discarded
      end

      it "stamps discarded_by on the employee" do
        expect(employee.reload.discarded_by_id).to eq(admin.id)
      end
    end

    context "when the employee is assigned to a truck" do
      let!(:truck) do
        Truck.create!(plate_number: "GN-#{SecureRandom.hex(3)}", make: "Volvo", model: "FH",
                      year: 2020, driver: employee)
      end

      before do
        Current.user = admin
        do_request
      end

      it "discards the employee" do
        expect(employee.reload).to be_discarded
      end

      it "clears the truck's driver assignment" do
        expect(truck.reload.driver_id).to be_nil
      end
    end

    context "when the employee has documents" do
      let!(:document) do
        Document.create!(documentable: employee, doc_type: :driver_license,
                         number: "LIC-#{SecureRandom.hex(4)}", title: "Driver Licence",
                         issued_on: Date.current - 365, expires_on: Date.current + 365)
      end

      before do
        Current.user = admin
        do_request
      end

      it "discards the employee's documents" do
        expect(document.reload).to be_discarded
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
    end
  end
end
