# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::BillingStatements::Generate do
  subject(:do_request) do
    post "/api/v1/billing_statements/generate", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:month)        { Time.zone.today.prev_month.beginning_of_month }
  let(:params)       { {month: month.to_s} }
  let(:truck)        { build_truck_with_tank(plate: "T-#{SecureRandom.hex(3)}") }
  let(:route)        { Route.create!(origin: "Conakry", destination: "Kankan", rate: 1_000) }

  def completed_trip_with_note(start_at:, gasoline: 10, diesel: 0)
    trip = Trip.create!(truck: truck, route: route, actual_start_at: start_at, status: :completed)
    DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(3)}",
                         gasoline_quantity: gasoline, diesel_quantity: diesel)
    trip
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

    it "returns the forbidden error code" do
      expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with completed trips in the month" do
      before { completed_trip_with_note(start_at: month + 5.days, gasoline: 10, diesel: 0) }

      it "creates a draft statement" do
        expect { do_request }.to change { BillingStatement.count }.by(1)
      end

      context "when the request is successful" do
        before { do_request }

        it "returns 201" do
          expect(response).to have_http_status(:created)
        end

        it "returns the draft status" do
          expect(response.parsed_body["status"]).to eq("draft")
        end

        it "computes the total HT from the completed trip" do
          expect(response.parsed_body["total_amount"]).to eq(10_000)
        end

        it "computes the TVA at 18%" do
          expect(response.parsed_body["total_tva"]).to eq(1_800)
        end

        it "computes the grand total TTC" do
          expect(response.parsed_body["grand_total"]).to eq(11_800)
        end
      end
    end

    context "with a trip that is not completed" do
      before do
        Trip.create!(truck: truck, route: route, actual_start_at: month + 5.days, status: :in_progress)
                .tap { |trip| DeliveryNote.create!(trip: trip, number: "DN-#{SecureRandom.hex(3)}", gasoline_quantity: 10) }
        do_request
      end

      it "does not bill the trip" do
        expect(response.parsed_body["total_amount"]).to eq(0)
      end
    end

    context "when a statement already exists for that month" do
      before do
        BillingStatement.create!(month: month, number: "S-#{SecureRandom.hex(2)}")
        completed_trip_with_note(start_at: month + 5.days)
      end

      it "does not create a second statement" do
        expect { do_request }.not_to change { BillingStatement.count }
      end

      it "returns the existing statement" do
        do_request
        expect(response.parsed_body["total_amount"]).to eq(0)
      end
    end

    context "with a missing month" do
      let(:params) { {} }

      before { do_request }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the validation_failed code" do
        expect(response.parsed_body.dig("error", "code")).to eq("validation_failed")
      end
    end
  end
end
