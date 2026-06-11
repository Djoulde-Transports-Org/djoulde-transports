# frozen_string_literal: true

# Trip fields and the delivery note's missing quantity are reconciled together.
# Missing quantity is recorded when the trip completes; when omitted it keeps
# its existing value (0 by default).
module Trips
  class Update < ApplicationService
    def initialize(trip, trip_params, missing_quantity = nil)
      @trip = trip
      @trip_params = trip_params
      @missing_quantity = missing_quantity
    end

    def call
      ApplicationRecord.transaction do
        @trip.update!(@trip_params)
        unless @missing_quantity.nil?
          @trip.delivery_note&.update!(missing_quantity: @missing_quantity)
        end
        @trip
      end
    end
  end
end
