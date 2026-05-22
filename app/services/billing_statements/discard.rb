# frozen_string_literal: true

# A statement carries kept line items that snapshot historical invoice rows.
# We refuse to discard the statement while those rows still exist; admins
# must void the statement instead.
module BillingStatements
  class Discard < ApplicationService
    def initialize(billing_statement)
      @billing_statement = billing_statement
    end

    def call
      if @billing_statement.billing_line_items.kept.exists?
        raise HasDependents, "statement still has kept billing line items"
      end

      ApplicationRecord.transaction do
        @billing_statement.documents.kept.find_each { |d| d.discard! }
        @billing_statement.discard!
      end
      @billing_statement
    end
  end
end
