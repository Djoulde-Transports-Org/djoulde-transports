# frozen_string_literal: true

# Routes are referenced by trips for the full history of a corridor. We block
# discard when any kept trip still uses the route; admins can rename or freeze
# rates instead.
module Routes
  class Discard < ApplicationService
    def initialize(route)
      @route = route
    end

    def call
      if @route.trips.kept.exists?
        raise HasDependents, "route still has #{@route.trips.kept.count} kept trip(s)"
      end

      @route.discard!
      @route
    end
  end
end
