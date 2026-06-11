# frozen_string_literal: true

# Updates a truck (head) and, when tank attributes are supplied, its tank in
# one transaction so a partial update never leaves the pair inconsistent.
module Trucks
  class Update < ApplicationService
    def initialize(truck, truck_attrs:, tank_attrs:)
      @truck       = truck
      @truck_attrs = truck_attrs
      @tank_attrs  = tank_attrs
    end

    def call
      ApplicationRecord.transaction do
        @truck.update!(@truck_attrs)
        @truck.tank.update!(@tank_attrs) if @tank_attrs.present?
        @truck
      end
    end

    private

    attr_reader :truck, :truck_attrs, :tank_attrs
  end
end
