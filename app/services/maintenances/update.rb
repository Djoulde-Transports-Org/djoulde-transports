# frozen_string_literal: true

# Updates a maintenance and, when a `parts` list is supplied, replaces its
# parts as a set: existing kept parts are discarded and the supplied ones are
# created. Omitting `parts` leaves the current parts untouched.
#
# Marking a maintenance completed stamps its actual duration from the elapsed
# time since it was opened and returns the truck to the ready status.
module Maintenances
  class Update < ApplicationService
    def initialize(maintenance, maintenance_params, parts_params = nil)
      @maintenance = maintenance
      @maintenance_params = maintenance_params
      @parts_params = parts_params
    end

    def call
      ApplicationRecord.transaction do
        was_completed = @maintenance.completed?
        @maintenance.assign_attributes(@maintenance_params)
        complete unless was_completed || !@maintenance.completed?
        @maintenance.save!

        unless @parts_params.nil?
          replace_parts
          @maintenance.recompute_cost!
        end
        @maintenance
      end
    end

    private

    def complete
      @maintenance.actual_duration = @maintenance.elapsed_hours
      @maintenance.truck.ready!
    end

    def replace_parts
      @maintenance.parts.kept.find_each(&:discard!)
      @parts_params.each { |attrs| @maintenance.parts.create!(attrs) }
    end
  end
end
