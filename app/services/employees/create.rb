# frozen_string_literal: true

module Employees
  class Create < ApplicationService
    def initialize(attrs:, created_by:)
      @attrs      = attrs
      @created_by = created_by
    end

    def call
      employee = ::Employee.new(employee_attrs)
      employee.created_by = @created_by
      employee.save!
      assign_truck!(employee)
      employee
    end

    private

    attr_reader :attrs, :created_by

    def employee_attrs
      attrs.except(:truck_id)
    end

    def assign_truck!(employee)
      return if attrs[:truck_id].blank?

      ::Truck.find(attrs[:truck_id]).update!(driver: employee)
    end
  end
end
