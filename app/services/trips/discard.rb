# frozen_string_literal: true

# Trips cascade to their delivery_note and documents. Once a trip has been
# billed (it appears on a kept billing_line_item), we refuse to discard it so
# historical invoices stay consistent.
module Trips
  class Discard < ApplicationService
    def initialize(trip)
      @trip = trip
    end

    def call
      if @trip.billing_line_items.kept.exists?
        raise HasDependents, "trip is already on a billing line item"
      end

      ApplicationRecord.transaction do
        DeliveryNotes::Discard.call(@trip.delivery_note) if @trip.delivery_note&.kept?
        @trip.documents.kept.find_each { |d| Documents::Discard.call(d) }
        @trip.discard!
      end
      @trip
    end
  end
end
