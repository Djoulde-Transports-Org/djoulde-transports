# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Employees::Update do
  subject(:do_request) do
    patch "/api/v1/employees/#{employee_id}/update", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {last_name: "Barry"} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
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
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the employee" do
        expect(employee.reload.last_name).to eq("Barry")
      end

      it "returns the updated last_name" do
        expect(response.parsed_body["last_name"]).to eq("Barry")
      end
    end

    context "when assigning a user_id" do
      let(:user) { User.create!(email: "driver3@example.com", password: "password123") }
      let(:params) { {user_id: user.id} }

      before { do_request }

      it "links the user account" do
        expect(employee.reload.user_id).to eq(user.id)
      end
    end

    context "when changing the role" do
      let(:params) { {role: "mechanic"} }

      before { do_request }

      it "updates the role" do
        expect(response.parsed_body["role"]).to eq("mechanic")
      end
    end

    context "with an invalid role" do
      let(:params) { {role: "superhero"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
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
