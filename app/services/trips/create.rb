# frozen_string_literal: true

# A trip is created from its delivery note: the note is the loading document
# and the source of truth, so the two are written together in one transaction.
module Trips
  class Create < ApplicationService
    def initialize(trip_params, delivery_note_params)
      @trip_params = trip_params
      @delivery_note_params = delivery_note_params
    end

    def call
      ApplicationRecord.transaction do
        trip = ::Trip.create!(@trip_params)
        note = trip.build_delivery_note(@delivery_note_params)
        note.save!(context: :trip_creation)
        trip
      end
    end
  end
end
