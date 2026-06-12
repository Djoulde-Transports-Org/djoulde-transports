# frozen_string_literal: true

# A truck (head) and its tank are registered as a unit: the schema pairs them
# 1:1 (`tanks.truck_id` is NOT NULL + UNIQUE), so we build both in one
# transaction. An invalid tank rolls back the truck, leaving no orphan head.
module Trucks
  class Create < ApplicationService
    def initialize(truck_attrs:, tank_attrs:, created_by:)
      @truck_attrs = truck_attrs
      @tank_attrs  = tank_attrs
      @created_by  = created_by
    end

    def call
      ApplicationRecord.transaction do
        truck = ::Truck.new(@truck_attrs)
        truck.created_by = @created_by
        truck.save!
        truck.create_tank!(@tank_attrs)
        truck
      end
    end

    private

    attr_reader :truck_attrs, :tank_attrs, :created_by
  end
end
