# frozen_string_literal: true

module Maintenances
  class Discard < ApplicationService
    def initialize(maintenance)
      @maintenance = maintenance
    end

    def call
      ApplicationRecord.transaction do
        @maintenance.documents.kept.find_each { |d| d.discard! }
        @maintenance.discard!
      end
      @maintenance
    end
  end
end
