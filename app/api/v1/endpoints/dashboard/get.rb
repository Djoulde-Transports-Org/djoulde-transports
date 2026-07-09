# frozen_string_literal: true

module API::V1::Endpoints::Dashboard
  class Get < Grape::API
    helpers do
      def truck_counts
        @truck_counts ||= ::Truck.kept.group(:status).count
      end

      def liters_delivered_this_month
        today = Time.zone.today
        ::DeliveryNote.kept
                      .joins(:trip)
                      .merge(::Trip.kept.started_in_month(today.year, today.month))
                      .sum("delivery_notes.gasoline_quantity + delivery_notes.diesel_quantity")
      end

      def billing_amount_ht_this_month
        ::BillingStatement.kept.for_month(Time.zone.today).pick(:total_amount) || 0
      end
    end

    resource :dashboard do
      desc "Return KPI aggregates for the dashboard."
      get do
        authorize!(:dashboard, :show)

        {
          trucks: {
            total:          truck_counts.values.sum,
            ready:          truck_counts["ready"] || 0,
            on_trip:        truck_counts["on_trip"] || 0,
            in_maintenance: truck_counts["in_maintenance"] || 0,
          },
          trips_in_progress:            ::Trip.kept.in_progress.count,
          liters_delivered_this_month:  liters_delivered_this_month,
          billing_amount_ht_this_month: billing_amount_ht_this_month,
        }
      end
    end
  end
end
