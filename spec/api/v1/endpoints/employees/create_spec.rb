# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Employees::Create do
  subject(:do_request) do
    post "/api/v1/employees/create", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin)        { admin_setup[0] }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:params) do
    {first_name: "Mamadou", last_name: "Diallo", phone_number: "+224 620 000 000", role: "driver"}
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
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    it "creates an employee" do
      expect { do_request }.to change { Employee.count }.by(1)
    end

    context "when the request is successful" do
      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the employee's last_name" do
        expect(response.parsed_body["last_name"]).to eq("Diallo")
      end

      it "returns the role" do
        expect(response.parsed_body["role"]).to eq("driver")
      end

      it "stamps created_by to the current user" do
        employee = Employee.last
        expect(employee.created_by_id).to eq(admin.id)
      end
    end

    context "with optional user_id" do
      let(:user) { User.create!(email: "driver@example.com", password: "password123") }
      let(:params) { super().merge(user_id: user.id) }

      before { do_request }

      it "links the user account" do
        expect(response.parsed_body["user_id"]).to eq(user.id)
      end
    end

    context "without a role (defaults to driver)" do
      let(:params) { super().except(:role) }

      before { do_request }

      it "returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "defaults the role to driver" do
        expect(response.parsed_body["role"]).to eq("driver")
      end
    end

    context "with missing required params" do
      let(:params) { {phone_number: "+224 620 000 001"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end

    context "with an invalid role" do
      let(:params) { super().merge(role: "superhero") }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a duplicate user_id" do
      let(:user) { User.create!(email: "driver2@example.com", password: "password123") }
      let!(:existing) { Employee.create!(first_name: "Ibra", last_name: "Sow", user: user) }
      let(:params) { super().merge(user_id: user.id) }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with address, hire_date and status" do
      let(:params) do
        super().merge(address: "12 Rue du Port, Conakry", hire_date: "2024-03-01", status: "on_leave")
      end

      before { do_request }

      it "returns the address" do
        expect(response.parsed_body["address"]).to eq("12 Rue du Port, Conakry")
      end

      it "returns the hire_date" do
        expect(response.parsed_body["hire_date"]).to eq("2024-03-01")
      end

      it "returns the status" do
        expect(response.parsed_body["status"]).to eq("on_leave")
      end
    end

    context "with a truck_id" do
      let(:truck)  { Truck.create!(plate_number: "GN-1000-A") }
      let(:params) { super().merge(truck_id: truck.id) }

      before { do_request }

      it "assigns the truck to the new employee" do
        expect(truck.reload.driver_id).to eq(response.parsed_body["id"])
      end

      it "returns the assigned_truck" do
        expect(response.parsed_body["assigned_truck"]).to eq(
          {"id" => truck.id, "plate_number" => "GN-1000-A"}
        )
      end
    end

    context "with a non-existent truck_id" do
      let(:params) { super().merge(truck_id: 999_999) }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
