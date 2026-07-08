# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trips::Get do
  subject(:do_request) { get "/api/v1/trips/#{trip_id}", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck)        { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
  let(:route)        { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }
  let(:trip)         { Trip.create!(truck: truck, route: route) }
  let(:trip_id)      { trip.id }
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

    context "for a kept trip" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the trip id" do
        expect(response.parsed_body["id"]).to eq(trip.id)
      end

      it "includes the nested delivery note" do
        expect(response.parsed_body.dig("delivery_note", "number")).to eq(note.number)
      end

      it "includes the nested truck with plate_number" do
        expect(response.parsed_body.dig("truck", "plate_number")).to eq(truck.plate_number)
      end

      it "includes the nested route origin and destination", :aggregate_failures do
        expect(response.parsed_body.dig("route", "origin")).to eq("Conakry")
        expect(response.parsed_body.dig("route", "destination")).to eq("Labe")
      end
    end

    context "for a discarded trip" do
      before do
        trip.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Trip not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Trip not found.")
      end
    end

    context "for a non-existent id" do
      let(:trip_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
