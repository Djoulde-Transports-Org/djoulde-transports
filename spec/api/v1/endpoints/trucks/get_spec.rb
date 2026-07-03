# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::Get do
  subject(:do_request) { get "/api/v1/trucks/#{truck_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) do
    Truck.create!(plate_number: "GN-#{SecureRandom.hex(3).upcase}", make: "Volvo", model: "FH", year: 2020)
  end
  let(:truck_id) { truck.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid token" do
    let(:headers) { bearer_headers(viewer_token) }

    context "for a kept truck" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the truck id" do
        expect(response.parsed_body["id"]).to eq(truck.id)
      end

      it "returns the truck plate_number" do
        expect(response.parsed_body["plate_number"]).to eq(truck.plate_number)
      end
    end

    context "for a discarded truck" do
      before do
        truck.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Truck not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Truck not found.")
      end
    end

    context "for a non-existent id" do
      let(:truck_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Truck not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Truck not found.")
      end
    end

    context "with last_oil_change_on" do
      context "when the truck has an oil change maintenance" do
        before do
          Maintenance.create!(truck: truck, kind: :oil_change, state: :completed,
                              performed_on: Date.new(2025, 3, 10))
          Maintenance.create!(truck: truck, kind: :oil_change, state: :completed,
                              performed_on: Date.new(2025, 6, 1))
          do_request
        end

        it "returns the most recent oil change date" do
          expect(response.parsed_body["last_oil_change_on"]).to eq("2025-06-01")
        end
      end

      context "when there are no oil change maintenances" do
        before do
          Maintenance.create!(truck: truck, kind: :routine, state: :completed,
                              performed_on: Date.new(2025, 1, 1))
          do_request
        end

        it "returns nil" do
          expect(response.parsed_body["last_oil_change_on"]).to be_nil
        end
      end

      context "when an oil change maintenance is discarded" do
        before do
          m = Maintenance.create!(truck: truck, kind: :oil_change, state: :completed,
                                  performed_on: Date.new(2025, 5, 1))
          m.discard
          do_request
        end

        it "excludes discarded maintenances" do
          expect(response.parsed_body["last_oil_change_on"]).to be_nil
        end
      end
    end

    context "with document expiry fields" do
      let(:future_date) { Date.current + 90 }
      let(:past_date)   { Date.current - 10 }

      before do
        Document.create!(documentable: truck, doc_type: :insurance, number: "INS-#{SecureRandom.hex(4)}",
                         title: "Truck Insurance", issued_on: Date.current - 365, expires_on: future_date)
        Document.create!(documentable: truck, doc_type: :inspection, number: "INS-#{SecureRandom.hex(4)}",
                         title: "Technical Inspection", issued_on: Date.current - 365, expires_on: past_date)
        do_request
      end

      it "returns truck_insurance_expires_on" do
        expect(response.parsed_body["truck_insurance_expires_on"]).to eq(future_date.iso8601)
      end

      it "returns a positive truck_insurance_days_remaining" do
        expect(response.parsed_body["truck_insurance_days_remaining"]).to be > 0
      end

      it "returns technical_inspection_expires_on" do
        expect(response.parsed_body["technical_inspection_expires_on"]).to eq(past_date.iso8601)
      end

      it "returns a negative technical_inspection_days_remaining for an expired document" do
        expect(response.parsed_body["technical_inspection_days_remaining"]).to be < 0
      end

      it "returns nil for cargo_insurance_expires_on when no registration document exists" do
        expect(response.parsed_body["cargo_insurance_expires_on"]).to be_nil
      end

      it "returns nil for cargo_insurance_days_remaining when no registration document exists" do
        expect(response.parsed_body["cargo_insurance_days_remaining"]).to be_nil
      end
    end

    context "when the truck has a driver" do
      let(:driver) { Employee.create!(first_name: "Mamadou", last_name: "Diallo") }

      before do
        truck.update!(driver: driver)
        do_request
      end

      it "returns the nested driver id" do
        expect(response.parsed_body.dig("driver", "id")).to eq(driver.id)
      end

      it "returns the nested driver first_name" do
        expect(response.parsed_body.dig("driver", "first_name")).to eq("Mamadou")
      end

      it "returns the nested driver last_name" do
        expect(response.parsed_body.dig("driver", "last_name")).to eq("Diallo")
      end
    end

    context "with stats fields" do
      it "returns trips_count as 0 when there are no trips" do
        do_request
        expect(response.parsed_body["trips_count"]).to eq(0)
      end

      it "returns total_km as 0.0 when there are no trips" do
        do_request
        expect(response.parsed_body["total_km"]).to eq(0.0)
      end

      it "returns total_liters_delivered as 0 when there are no delivery notes" do
        do_request
        expect(response.parsed_body["total_liters_delivered"]).to eq(0)
      end
    end
  end
end
