# frozen_string_literal: true

module Employees
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(employee)
      @employee = employee
    end

    def call
      ApplicationRecord.transaction do
        # Unassign the driver from their truck so the truck isn't left with a
        # reference to a discarded employee.
        ::Truck.find_by(driver_id: @employee.id)&.update!(driver_id: nil)
        @employee.documents.kept.find_each { |d| Documents::Discard.call(d) }
        @employee.discard!
      end
      Result.new(success: true, message: "Employee has been successfully deleted.")
    end

    private

    attr_reader :employee
  end
end
