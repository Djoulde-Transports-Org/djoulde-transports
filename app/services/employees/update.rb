# frozen_string_literal: true

module Employees
  class Update < ApplicationService
    def initialize(employee, attrs:)
      @employee = employee
      @attrs    = attrs
    end

    def call
      @employee.update!(employee_attrs)
      assign_truck! if attrs.key?(:truck_id)
      @employee
    end

    private

    attr_reader :employee, :attrs

    def employee_attrs
      attrs.except(:truck_id)
    end

    def assign_truck!
      ::Truck.where(driver_id: employee.id).where.not(id: attrs[:truck_id]).update!(driver_id: nil)
      ::Truck.find(attrs[:truck_id]).update!(driver: employee) if attrs[:truck_id].present?
    end
  end
end
