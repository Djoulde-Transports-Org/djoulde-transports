# frozen_string_literal: true

# Discards a Truck. Later branches extend this service to cascade to the
# (truck has_one) tank, its trips, maintenances, and documents as those
# resources land.
module Trucks
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

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

      Result.new(success: true, message: "Truck has been successfully deleted.")
    end

    private

    attr_reader :truck
  end
end
