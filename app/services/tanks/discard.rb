# frozen_string_literal: true

# A tank that has been used on a kept trip is part of history we don't want
# to detach. Block the discard until those trips are reassigned or retired.
module Tanks
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(tank)
      @tank = tank
    end

    def call
      if @tank.trips.kept.exists?
        raise HasDependents, "tank still has #{@tank.trips.kept.count} kept trip(s)"
      end

      ApplicationRecord.transaction do
        @tank.documents.kept.find_each { |d| d.discard! }
        @tank.discard!
      end

      Result.new(success: true, message: "Tank has been successfully deleted.")
    end

    private

    attr_reader :tank
  end
end
