# frozen_string_literal: true

module Employees
  class Create < ApplicationService
    def initialize(attrs:, created_by:)
      @attrs      = attrs
      @created_by = created_by
    end

    def call
      employee = ::Employee.new(@attrs)
      employee.created_by = @created_by
      employee.save!
      employee
    end

    private

    attr_reader :attrs, :created_by
  end
end
