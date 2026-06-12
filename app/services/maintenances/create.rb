# frozen_string_literal: true

# A maintenance is created together with the parts that were changed, so the
# record and its line items are written in one transaction. Opening a
# maintenance also moves the truck into the in_maintenance status.
module Maintenances
  class Create < ApplicationService
    def initialize(maintenance_params, parts_params = nil)
      @maintenance_params = maintenance_params
      @parts_params = parts_params || []
    end

    def call
      ApplicationRecord.transaction do
        maintenance = ::Maintenance.create!(@maintenance_params)
        @parts_params.each { |attrs| maintenance.parts.create!(attrs) }
        maintenance.recompute_cost!
        maintenance.truck.in_maintenance!
        maintenance
      end
    end
  end
end
