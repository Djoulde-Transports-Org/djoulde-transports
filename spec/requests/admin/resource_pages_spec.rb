# frozen_string_literal: true

# Coverage for the admin pages changed after ticket 12: trips as the admin root,
# the truck<->tank cross-links, the extra trip columns/rows, and a smoke check
# that every resource index/show renders (this is what would have caught the
# removed `active_admin_comments` helper across all resources).
RSpec.describe "Admin resource pages", type: :request do
  let(:html) { {"Accept" => "text/html"} }
  let(:admin) { create_admin }

  let(:route) { Route.create!(origin: "Conakry", destination: "Labe", rate: 250) }
  let(:truck) { Truck.create!(plate_number: "TRK-1", year: 2020) }
  let(:tank)  { Tank.create!(truck: truck, plate_number: "TNK-1", capacity: 30_000, year: 2020) }
  let(:trip)  { Trip.create!(truck: truck, tank: tank, route: route) }
  let(:delivery_note) do
    DeliveryNote.create!(trip: trip, number: "DN-001",
      gasoline_quantity: 10_000, diesel_quantity: 5_000, missing_quantity: 0)
  end

  before { sign_in admin }

  describe "admin root" do
    it "routes /admin to the trips index" do
      expect(Rails.application.routes.recognize_path("/admin"))
        .to eq(controller: "admin/trips", action: "index")
    end

    it "renders the trips index at the root" do
      get "/admin", headers: html
      expect(response).to have_http_status(:ok)
    end
  end

  describe "trucks <-> tank cross-links" do
    it "links to the tank from the trucks index", :aggregate_failures do
      tank
      get "/admin/trucks", headers: html
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(admin_tank_path(tank))
    end

    it "shows a Tank panel linking to the tank on the truck show page", :aggregate_failures do
      tank
      get "/admin/trucks/#{truck.id}", headers: html
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tank", admin_tank_path(tank))
    end

    it "shows a placeholder when the truck has no tank" do
      lonely = Truck.create!(plate_number: "TRK-2", year: 2021)
      get "/admin/trucks/#{lonely.id}", headers: html
      expect(response.body).to include("No tank assigned")
    end
  end

  describe "trip origin/destination/quantities/delivery note" do
    it "shows them on the trips index", :aggregate_failures do
      delivery_note
      get "/admin/trips", headers: html
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Conakry", "Labe", "10000", "5000", "DN-001")
      expect(response.body).to include(admin_delivery_note_path(delivery_note))
    end

    it "shows them on the trip show page", :aggregate_failures do
      delivery_note
      get "/admin/trips/#{trip.id}", headers: html
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Conakry", "Labe", "10000", "5000", "DN-001")
    end
  end

  describe "resource index pages render" do
    %w[routes trucks tanks trips users delivery_notes].each do |path|
      it "GET /admin/#{path} returns 200" do
        delivery_note # build the full graph so list pages have rows to render
        get "/admin/#{path}", headers: html
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
