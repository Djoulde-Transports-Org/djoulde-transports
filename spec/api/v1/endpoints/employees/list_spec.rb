# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Employees::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/employees#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let!(:employee) do
    Employee.create!(first_name: "Mamadou", last_name: "Diallo", role: :driver)
  end

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns an array" do
      expect(response.parsed_body).to be_an(Array)
    end

    it "includes the employee" do
      expect(response.parsed_body.pluck("id")).to include(employee.id)
    end
  end

  context "when an employee is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      employee.discard
      do_request
    end

    it "excludes discarded employees" do
      expect(response.parsed_body.pluck("id")).not_to include(employee.id)
    end
  end

  context "with pagination" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:extra_employees) do
      Array.new(4) do |i|
        Employee.create!(first_name: "Driver", last_name: "Extra#{i}", role: :driver)
      end
    end

    context "with per_page=2" do
      let(:params) { {page: 1, per_page: 2} }

      before { do_request }

      it "returns 2 records" do
        expect(response.parsed_body.size).to eq(2)
      end

      it "sets Total and Per-Page headers", :aggregate_failures do
        expect(response.headers["Total"]).to eq("5")
        expect(response.headers["Per-Page"]).to eq("2")
      end
    end
  end

  context "with a role filter" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:mechanic) { Employee.create!(first_name: "Ali", last_name: "Bah", role: :mechanic) }

    context "when filtering by driver" do
      let(:params) { {role: "driver"} }

      before { do_request }

      it "returns only drivers", :aggregate_failures do
        ids = response.parsed_body.pluck("id")
        expect(ids).to include(employee.id)
        expect(ids).not_to include(mechanic.id)
      end
    end

    context "with an invalid role value" do
      let(:params) { {role: "superstar"} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  context "with a search filter" do
    let(:headers) { bearer_headers(viewer_token) }
    let!(:other) { Employee.create!(first_name: "Ibra", last_name: "Sow", role: :driver) }

    context "when searching by last name prefix" do
      let(:params) { {search: "DIA"} }

      before { do_request }

      it "returns the matching employee" do
        expect(response.parsed_body.pluck("id")).to include(employee.id)
      end

      it "excludes non-matching employees" do
        expect(response.parsed_body.pluck("id")).not_to include(other.id)
      end
    end

    context "when searching case-insensitively" do
      let(:params) { {search: "dia"} }

      before { do_request }

      it "returns the matching employee" do
        expect(response.parsed_body.pluck("id")).to include(employee.id)
      end
    end
  end
end
