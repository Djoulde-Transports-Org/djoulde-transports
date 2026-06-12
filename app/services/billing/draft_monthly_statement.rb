# frozen_string_literal: true

# Builds the draft `BillingStatement` for a given month and materializes one
# `BillingLineItem` per billable trip via `BillingLineItem.from_trip`.
#
# Idempotent per month: re-running on the same month is a no-op once the
# statement exists. Tracked recurring entry lives in `config/recurring.yml`.
module Billing
  class DraftMonthlyStatement < ApplicationService
    NumberFormat = "%<year>04d-%<month>02d"

    def initialize(month: Time.zone.today.prev_month.beginning_of_month)
      @month = month.to_date.beginning_of_month
    end

    def call
      existing = BillingStatement.for_month(@month).first
      return existing if existing

      ApplicationRecord.transaction do
        statement = BillingStatement.create!(month: @month, number: build_number)
        billable_trips.find_each do |trip|
          BillingLineItem.from_trip(trip, billing_statement: statement).save!
        end
        statement.recalculate_total!
        statement
      end
    end

    private

    def build_number
      format(NumberFormat, year: @month.year, month: @month.month)
    end

    def billable_trips
      Trip
        .kept
        .where(actual_start_at: @month.beginning_of_day...@month.next_month.beginning_of_day)
        .joins(:delivery_note)
        .where(delivery_notes: {discarded_at: nil})
    end
  end
end
