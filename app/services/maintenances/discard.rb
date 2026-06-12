# frozen_string_literal: true

# Maintenances cascade to their documents and parts on discard.
module Maintenances
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(maintenance)
      @maintenance = maintenance
    end

    def call
      ApplicationRecord.transaction do
        @maintenance.documents.kept.find_each { |d| d.discard! }
        @maintenance.parts.kept.find_each { |p| p.discard! }
        @maintenance.discard!
      end

      Result.new(success: true, message: "Maintenance has been successfully deleted.")
    end

    private

    attr_reader :maintenance
  end
end
