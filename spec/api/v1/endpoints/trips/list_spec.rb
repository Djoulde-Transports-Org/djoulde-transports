# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trips::List do
  subject(:do_request) do
    query = params.any? ? "?#{params.to_query}" : ""
    get "/api/v1/trips#{query}", headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route)        { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }
  let!(:trip)        { Trip.create!(truck: truck, route: route) }
  let!(:note) do
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                         gasoline_quantity: 5, diesel_quantity: 0)
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

    it "returns kept trips in the items array" do
      expect(response.parsed_body["items"].pluck("id")).to include(trip.id)
    end

    it "includes has_more in the response" do
      expect(response.parsed_body).to have_key("has_more")
    end

    it "includes next_cursor in the response" do
      expect(response.parsed_body).to have_key("next_cursor")
    end

    it "includes each trip's nested delivery note" do
      row = response.parsed_body["items"].find { |t| t["id"] == trip.id }
      expect(row.dig("delivery_note", "number")).to eq(note.number)
    end

    it "includes the full nested truck with plate_number" do
      row = response.parsed_body["items"].find { |t| t["id"] == trip.id }
      expect(row.dig("truck", "plate_number")).to eq(truck.plate_number)
    end

    it "includes the nested route origin and destination", :aggregate_failures do
      row = response.parsed_body["items"].find { |t| t["id"] == trip.id }
      expect(row.dig("route", "origin")).to eq("Conakry")
      expect(row.dig("route", "destination")).to eq("Labe")
    end
  end

  context "when a trip is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      trip.discard
      do_request
    end

    it "excludes discarded trips" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(trip.id)
    end
  end

  context "when filtering by truck_id" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {truck_id: truck.id} }
    let!(:other_trip) do
      Trip.create!(truck: build_truck_with_tank(plate: "T-other"), route: route)
    end

    before { do_request }

    it "returns only trips for that truck" do
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(trip.id)
    end
  end

  context "when filtering by status" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {status: "completed"} }
    let!(:completed_trip) do
      Trip.create!(truck: build_truck_with_tank(plate: "T-done"), route: route, status: :completed)
    end

    before { do_request }

    it "returns only trips with that status" do
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(completed_trip.id)
    end
  end

  context "when status is not a valid value" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:params)  { {status: "nope"} }

    before { do_request }

    it "returns 422" do
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  context "when filtering by driver_id" do
    let(:headers)  { bearer_headers(viewer_token) }
    let(:driver)   { Employee.create!(first_name: "Ibra", last_name: "Bah") }
    let(:params)   { {driver_id: driver.id} }
    let!(:assigned_trip) do
      Trip.create!(truck: build_truck_with_tank(plate: "T-driver"), route: route, driver: driver)
    end

    before { do_request }

    it "returns only trips for that driver" do
      expect(response.parsed_body["items"].pluck("id")).to contain_exactly(assigned_trip.id)
    end
  end

  context "when filtering by truck_plate prefix" do
    let(:headers)         { bearer_headers(viewer_token) }
    let(:params)          { {truck_plate: "GN-SEARCH"} }
    let!(:matched_trip)   { Trip.create!(truck: build_truck_with_tank(plate: "GN-SEARCH-01"), route: route) }
    let!(:unmatched_trip) { Trip.create!(truck: build_truck_with_tank(plate: "SN-OTHER"), route: route) }

    before { do_request }

    it "includes trips whose truck plate starts with the prefix" do
      expect(response.parsed_body["items"].pluck("id")).to include(matched_trip.id)
    end

    it "excludes trips whose truck plate does not match the prefix" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(unmatched_trip.id)
    end
  end

  context "when filtering by date_from" do
    let(:headers)      { bearer_headers(viewer_token) }
    let(:params)       { {date_from: "2026-06-01"} }
    let!(:recent_trip) do
      Trip.create!(truck: build_truck_with_tank(plate: "T-recent"),
                   route: route, scheduled_start_at: Time.zone.local(2026, 6, 15, 8))
    end
    let!(:old_trip) do
      Trip.create!(truck: build_truck_with_tank(plate: "T-old"),
                   route: route, scheduled_start_at: Time.zone.local(2025, 12, 1, 8))
    end

    before { do_request }

    it "includes trips on or after date_from" do
      expect(response.parsed_body["items"].pluck("id")).to include(recent_trip.id)
    end

    it "excludes trips before date_from" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(old_trip.id)
    end
  end

  context "when filtering by date_to" do
    let(:headers)  { bearer_headers(viewer_token) }
    let(:params)   { {date_to: "2025-12-31"} }
    let!(:old_trip) do
      Trip.create!(truck: build_truck_with_tank(plate: "T-old2"),
                   route: route, scheduled_start_at: Time.zone.local(2025, 11, 1, 8))
    end
    let!(:new_trip) do
      Trip.create!(truck: build_truck_with_tank(plate: "T-new2"),
                   route: route, scheduled_start_at: Time.zone.local(2026, 3, 1, 8))
    end

    before { do_request }

    it "includes trips on or before date_to" do
      expect(response.parsed_body["items"].pluck("id")).to include(old_trip.id)
    end

    it "excludes trips after date_to" do
      expect(response.parsed_body["items"].pluck("id")).not_to include(new_trip.id)
    end
  end

  context "when paginating with a cursor" do
    let(:headers)       { bearer_headers(viewer_token) }
    let(:kindia_route)  { Route.create!(origin: "Conakry", destination: "Kindia", rate: 800) }

    before do
      # trip already exists; create 2 more so we have 3 total
      Trip.create!(truck: build_truck_with_tank(plate: "T-p2"), route: kindia_route)
      Trip.create!(truck: build_truck_with_tank(plate: "T-p3"), route: kindia_route)
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
        get "/api/v1/trips?limit=2", headers: headers
        cursor = response.parsed_body["next_cursor"]
        get "/api/v1/trips?limit=2&after=#{cursor}", headers: headers
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
