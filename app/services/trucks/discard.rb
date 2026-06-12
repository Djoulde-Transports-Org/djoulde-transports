# frozen_string_literal: true

# Discards a Truck. Blocks if the truck still has a paired kept tank
# (`tanks.truck_id NOT NULL` means the tank can't be left orphaned).
# Cascades to kept trips, maintenances, and documents inline; later
# branches will swap those inline `discard!` calls for the per-resource
# discard service objects.
module Trucks
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(truck)
      @truck = truck
    end

    def call
      if @truck.tank&.kept?
        raise HasDependents,
              "truck has a kept tank; reassign or retire the tank before discarding the head"
      end

      ApplicationRecord.transaction do
        @truck.trips.kept.find_each        { |trip| trip.discard! }
        @truck.maintenances.kept.find_each { |m|    Maintenances::Discard.call(m) }
        @truck.documents.kept.find_each    { |d|    d.discard! }
        @truck.discard!
      end

      Result.new(success: true, message: "Truck has been successfully deleted.")
    end

    private

    attr_reader :truck
  end
end
