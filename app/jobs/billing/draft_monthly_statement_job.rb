# frozen_string_literal: true

module Billing
  class DraftMonthlyStatementJob < ApplicationJob
    queue_as :default

    def perform(month = nil)
      target = month.present? ? Date.parse(month.to_s).beginning_of_month : Time.zone.today.prev_month.beginning_of_month
      Billing::DraftMonthlyStatement.call(month: target)
    end
  end
end
