# frozen_string_literal: true

# DeliveryNote is `has_one` on Trip, so the API nests it under the parent.
module API::V1
  class DeliveryNotes < Grape::API
    before { authenticate! }

    helpers do
      def delivery_note_params
        declared(params, include_missing: false).slice(
          :number, :delivered_on, :quantity_gasoline_liters, :quantity_diesel_liters
        )
      end

      def parent_trip
        @parent_trip ||= find_kept!(::Trip, id_param: :trip_id)
      end
    end

    namespace "trips/:trip_id" do
      resource :delivery_note do
        desc "Get the trip's delivery note."
        get do
          authorize!(::DeliveryNote, :show)
          note = parent_trip.delivery_note
          not_found! if note.nil? || note.discarded?
          present note, with: API::V1::Entities::DeliveryNote
        end

        desc "Create the delivery note for a trip."
        params do
          requires :number,                   type: String
          optional :delivered_on,             type: Date
          optional :quantity_gasoline_liters, type: BigDecimal, default: 0
          optional :quantity_diesel_liters,   type: BigDecimal, default: 0
        end
        post do
          authorize!(::DeliveryNote, :create)
          note = parent_trip.build_delivery_note(delivery_note_params)
          note.save!
          present note, with: API::V1::Entities::DeliveryNote
        end

        desc "Update the trip's delivery note."
        params do
          optional :number,                   type: String
          optional :delivered_on,             type: Date
          optional :quantity_gasoline_liters, type: BigDecimal
          optional :quantity_diesel_liters,   type: BigDecimal
        end
        patch do
          note = parent_trip.delivery_note
          not_found! if note.nil? || note.discarded?
          authorize!(note, :update)
          note.update!(delivery_note_params)
          present note, with: API::V1::Entities::DeliveryNote
        end

        desc "Soft-delete the trip's delivery note."
        delete do
          note = parent_trip.delivery_note
          not_found! if note.nil? || note.discarded?
          authorize!(note, :destroy)
          ::DeliveryNotes::Discard.call(note)
          status 204
          body false
        end
      end
    end
  end
end
