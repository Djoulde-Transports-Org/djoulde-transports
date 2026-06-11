# frozen_string_literal: true

# Trips cascade to their delivery_note and documents. Once a trip has been
# billed (it appears on a kept billing_line_item), we refuse to discard it so
# historical invoices stay consistent.
module Trips
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(trip)
      @trip = trip
    end

    def call
      if @trip.billing_line_items.kept.exists?
        raise HasDependents, "trip is already on a billing line item"
      end

      ApplicationRecord.transaction do
        @trip.delivery_note&.discard! if @trip.delivery_note&.kept?
        @trip.documents.kept.find_each { |d| d.discard! }
        @trip.discard!
      end

      Result.new(success: true, message: "Trip has been successfully deleted.")
    end
  end
end
