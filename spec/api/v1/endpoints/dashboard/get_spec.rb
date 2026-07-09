# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Dashboard::Get do
  subject(:do_request) { get "/api/v1/dashboard", headers: headers }

  let(:headers)      { {} }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }

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

    it "includes the trucks breakdown" do
      expect(response.parsed_body).to have_key("trucks")
    end

    it "includes trips_in_progress" do
      expect(response.parsed_body).to have_key("trips_in_progress")
    end

    it "includes liters_delivered_this_month" do
      expect(response.parsed_body).to have_key("liters_delivered_this_month")
    end

    it "includes billing_amount_ht_this_month" do
      expect(response.parsed_body).to have_key("billing_amount_ht_this_month")
    end
  end

  context "with trucks in each status" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      Truck.create!(plate_number: "T-READY-1")
      Truck.create!(plate_number: "T-READY-2")
      Truck.create!(plate_number: "T-MAINT-1", status: :in_maintenance)
      Truck.create!(plate_number: "T-TRIP-1",  status: :on_trip)
      do_request
    end

    it "returns the correct total" do
      expect(response.parsed_body.dig("trucks", "total")).to eq(4)
    end

    it "returns the correct ready count" do
      expect(response.parsed_body.dig("trucks", "ready")).to eq(2)
    end

    it "returns the correct in_maintenance count" do
      expect(response.parsed_body.dig("trucks", "in_maintenance")).to eq(1)
    end

    it "returns the correct on_trip count" do
      expect(response.parsed_body.dig("trucks", "on_trip")).to eq(1)
    end
  end

  context "with trips in progress" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:truck)   { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}") }
    let(:route)   { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }

    before do
      Trip.create!(truck: truck, route: route, status: :in_progress)
      Trip.create!(truck: build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}"), route: route, status: :completed)
      do_request
    end

    it "counts only in_progress trips" do
      expect(response.parsed_body["trips_in_progress"]).to eq(1)
    end
  end

  context "with delivery notes for trips started this month" do
    let(:headers) { bearer_headers(viewer_token) }
    let(:truck)   { build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}", capacity: 1_000) }
    let(:route)   { Route.create!(origin: "Conakry", destination: "Labe", rate: 1500) }

    before do
      trip = Trip.create!(truck: truck, route: route, actual_start_at: Time.zone.now)
      DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(2)}",
                           gasoline_quantity: 600, diesel_quantity: 400)

      old_trip = Trip.create!(truck: build_truck_with_tank(plate: "T-#{SecureRandom.hex(2)}", capacity: 500),
                              route: route, actual_start_at: 2.months.ago)
      DeliveryNote.create!(trip: old_trip, number: "DN-#{SecureRandom.hex(2)}",
                           gasoline_quantity: 300, diesel_quantity: 200)

      do_request
    end

    it "sums only liters from trips started this month" do
      expect(response.parsed_body["liters_delivered_this_month"]).to eq(1000)
    end
  end

  context "with a billing statement for the current month" do
    let(:headers) { bearer_headers(viewer_token) }

    before do
      BillingStatement.create!(
        number: "BS-#{SecureRandom.hex(2)}",
        month: Time.zone.today.beginning_of_month,
        total_amount: 750_000,
        total_tva: 135_000,
        grand_total: 885_000
      )
      do_request
    end

    it "returns the current month billing HT" do
      expect(response.parsed_body["billing_amount_ht_this_month"]).to eq(750_000)
    end
  end

  context "with no billing statement for the current month" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 0 for billing_amount_ht_this_month" do
      expect(response.parsed_body["billing_amount_ht_this_month"]).to eq(0)
    end
  end
end
