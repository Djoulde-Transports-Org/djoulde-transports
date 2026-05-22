# frozen_string_literal: true

# Discards a Truck. Later branches extend this service to cascade to the
# (truck has_one) tank, its trips, maintenances, and documents as those
# resources land.
module Trucks
  class Discard < ApplicationService
    def initialize(truck)
      @truck = truck
    end

    def call
      ApplicationRecord.transaction do
        @truck.trips.kept.find_each        { |trip| trip.discard! }
        @truck.maintenances.kept.find_each { |m|    m.discard! }
        @truck.documents.kept.find_each    { |d|    d.discard! }
        @truck.discard!
      end
      @truck
    end
  end
end
