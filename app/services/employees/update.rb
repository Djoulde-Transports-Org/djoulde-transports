# frozen_string_literal: true

module Employees
  class Update < ApplicationService
    def initialize(employee, attrs:)
      @employee = employee
      @attrs    = attrs
    end

    def call
      @employee.update!(@attrs)
      @employee
    end

    private

    attr_reader :employee, :attrs
  end
end
