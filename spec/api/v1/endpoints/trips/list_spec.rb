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

    it "returns kept trips" do
      expect(response.parsed_body.pluck("id")).to include(trip.id)
    end

    it "includes each trip's nested delivery note" do
      row = response.parsed_body.find { |t| t["id"] == trip.id }
      expect(row.dig("delivery_note", "number")).to eq(note.number)
    end

    it "sets pagination headers", :aggregate_failures do
      expect(response.headers["Total"]).to eq("1")
      expect(response.headers["Per-Page"]).to eq("25")
    end
  end

  context "when a trip is discarded" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      trip.discard
      do_request
    end

    it "excludes discarded trips" do
      expect(response.parsed_body.pluck("id")).not_to include(trip.id)
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
      expect(response.parsed_body.pluck("id")).to contain_exactly(trip.id)
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
      expect(response.parsed_body.pluck("id")).to contain_exactly(completed_trip.id)
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
end
