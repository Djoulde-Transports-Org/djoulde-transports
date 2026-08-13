# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Maintenances::Update do
  subject(:do_request) do
    patch "/api/v1/maintenances/#{maintenance_id}/update", params: params, headers: headers
  end

  let(:headers)        { {} }
  let(:params)         { {estimated_duration: 4.0} }
  let(:admin_setup)    { auth_setup(role: :super_admin) }
  let(:admin_token)    { admin_setup[1] }
  let(:viewer_setup)   { auth_setup(role: :driver_readonly) }
  let(:viewer_token)   { viewer_setup[1] }
  let(:truck)          { Truck.create!(plate_number: "T-#{SecureRandom.hex(2)}") }
  let(:maintenance)    { Maintenance.create!(truck: truck, performed_on: Time.zone.today, kind: :routine) }
  let(:maintenance_id) { maintenance.id }

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

    context "with a kept maintenance" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the estimated duration" do
        expect(maintenance.reload.estimated_duration).to eq(4.0)
      end

      it "returns the updated estimated duration" do
        expect(response.parsed_body["estimated_duration"].to_f).to eq(4.0)
      end
    end

    context "when updating to a kind that doesn't exist yet" do
      let(:params) { {kind: "brake overhaul"} }

      before { maintenance } # memoize first so its default "routine" kind isn't created inside the expect block

      it "creates a new maintenance kind" do
        expect { do_request }.to change { MaintenanceKind.count }.by(1)
      end

      it "updates the maintenance's kind" do
        do_request
        expect(maintenance.reload.kind).to eq("brake overhaul")
      end
    end

    context "when completing the maintenance" do
      let(:params) { {state: "completed"} }

      before do
        truck.in_maintenance!
        travel_to(2.hours.ago) { maintenance } # open the maintenance 2 hours ago
        do_request
      end

      it "marks the maintenance completed" do
        expect(maintenance.reload).to be_completed
      end

      it "stamps the actual duration from the elapsed time" do
        expect(maintenance.reload.actual_duration).to eq(2.0)
      end

      it "returns the truck to the ready status" do
        expect(truck.reload).to be_ready
      end
    end

    context "when updating the parts" do
      let(:params) do
        {parts: [ {name: "alternator", price: 4500}, {name: "serpentine belt", price: 900} ]}
      end

      before do
        maintenance.parts.create!(name: "old part", price: 100)
        do_request
      end

      it "replaces the existing parts" do
        expect(maintenance.parts.kept.pluck(:name, :price))
          .to contain_exactly([ "alternator", 4500 ], [ "serpentine belt", 900 ])
      end

      it "returns the updated parts" do
        expect(response.parsed_body["parts"].pluck("name"))
          .to contain_exactly("alternator", "serpentine belt")
      end

      it "recomputes the cost from the new part prices" do
        expect(maintenance.reload.cost).to eq(5400)
      end
    end

    context "when estimated_duration is negative" do
      let(:params) { {estimated_duration: -1} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a discarded maintenance" do
      before do
        maintenance.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a non-existent id" do
      let(:maintenance_id) { 999_999 }

      before { do_request }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
