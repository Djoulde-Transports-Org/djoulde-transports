# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Maintenances::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/maintenances#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let!(:maintenance) { Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :routine) }

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

    it "returns kept maintenances in the items array" do
      expect(response.parsed_body["items"].pluck("id")).to include(maintenance.id)
    end

    it "includes has_more in the response" do
      expect(response.parsed_body).to have_key("has_more")
    end

    it "includes next_cursor in the response" do
      expect(response.parsed_body).to have_key("next_cursor")
    end

    it "includes the truck's plate_number for each item" do
      item = response.parsed_body["items"].find { |i| i["id"] == maintenance.id }
      expect(item.dig("truck", "plate_number")).to eq(truck.plate_number)
    end
  end

  context "when a maintenance is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      maintenance.discard
      do_request
    end

    it "excludes discarded maintenances" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(maintenance.id)
    end
  end

  context "when filtering by truck_id" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {truck_id: truck.id} }
    let!(:other_maintenance) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-other"), performed_on: Time.zone.today)
    end

    before { do_request }

    it "returns only maintenances for that truck" do
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(maintenance.id)
    end
  end

  context "when filtering by kind" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {kind: "repair"} }
    let!(:repair) do
      Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :repair)
    end

    before { do_request }

    it "returns only maintenances with that kind" do
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(repair.id)
    end
  end

  context "when filtering by a kind that doesn't exist" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {kind: "nope"} }

    before { do_request }

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns no items" do
      expect(response.parsed_body["items"]).to be_empty
    end
  end

  context "when filtering by state" do
    let(:headers)    { bearer_headers(viewer_token) }
    let(:params)     { {state: "completed"} }
    let!(:completed) do
      Maintenance.create!(truck: truck, performed_on: Time.zone.today, state: :completed)
    end

    before { do_request }

    it "returns only maintenances with that state" do
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(completed.id)
    end
  end

  context "when state is not a valid value" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {state: "nope"} }

    before { do_request }

    it "returns 422" do
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  context "when filtering by date_from" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {date_from: "2026-06-01"} }
    let!(:recent) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-recent"), performed_on: Date.new(2026, 6, 15))
    end
    let!(:old) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-old"), performed_on: Date.new(2025, 12, 1))
    end

    before { do_request }

    it "includes maintenances on or after date_from" do
      expect(response.parsed_body["items"].pluck("id")).to include(recent.id)
    end

    it "excludes maintenances before date_from" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(old.id)
    end
  end

  context "when filtering by date_to" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {date_to: "2025-12-31"} }
    let!(:old) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-old2"), performed_on: Date.new(2025, 11, 1))
    end
    let!(:recent) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-new2"), performed_on: Date.new(2026, 3, 1))
    end

    before { do_request }

    it "includes maintenances on or before date_to" do
      expect(response.parsed_body["items"].pluck("id")).to include(old.id)
    end

    it "excludes maintenances after date_to" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(recent.id)
    end
  end

  context "when filtering by search" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {search: "brake"} }
    let!(:matching_description) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-desc"), performed_on: Time.zone.today,
                          description: "Replaced brake pads")
    end
    let!(:matching_plate) do
      Maintenance.create!(truck: Truck.create!(plate_number: "BRAKE-1"), performed_on: Time.zone.today)
    end
    let!(:non_matching) do
      Maintenance.create!(truck: Truck.create!(plate_number: "T-other2"), performed_on: Time.zone.today,
                          description: "Oil change")
    end

    before { do_request }

    it "includes maintenances whose description matches" do
      expect(response.parsed_body["items"].pluck("id")).to include(matching_description.id)
    end

    it "includes maintenances whose truck plate_number matches" do
      expect(response.parsed_body["items"].pluck("id")).to include(matching_plate.id)
    end

    it "excludes maintenances that don't match" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(non_matching.id)
    end
  end

  context "when paginating with a cursor" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      # maintenance already exists; create 2 more so we have 3 total
      Maintenance.create!(truck: truck, performed_on: Time.zone.today)
      Maintenance.create!(truck: truck, performed_on: Time.zone.today)
    end

    context "with the first page and limit=2" do
      let(:params) { {limit: 2} }

      before { do_request }

      it "returns 2 items" do
        expect(response.parsed_body["items"].size).to eq(2)
      end

      it "sets has_more to true" do
        expect(response.parsed_body["has_more"]).to be true
      end

      it "returns a next_cursor" do
        expect(response.parsed_body["next_cursor"]).to be_present
      end
    end

    context "with the second page using the cursor from the first page" do
      before do
        get "/api/v1/maintenances?limit=2", headers: headers
        cursor = response.parsed_body["next_cursor"]
        get "/api/v1/maintenances?limit=2&after=#{cursor}", headers: headers
      end

      it "returns the remaining item" do
        expect(response.parsed_body["items"].size).to eq(1)
      end

      it "sets has_more to false" do
        expect(response.parsed_body["has_more"]).to be false
      end

      it "returns nil next_cursor" do
        expect(response.parsed_body["next_cursor"]).to be_nil
      end
    end

    context "when limit is out of range" do
      let(:params) { {limit: 200} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
