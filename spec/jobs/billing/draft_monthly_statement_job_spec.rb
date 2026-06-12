# frozen_string_literal: true

require "rails_helper"

RSpec.describe Billing::DraftMonthlyStatementJob do
  it "delegates to the service with last month by default" do
    expected_month = Time.zone.today.prev_month.beginning_of_month
    expect(Billing::DraftMonthlyStatement).to receive(:call).with(month: expected_month)
    described_class.perform_now
  end

  it "accepts an explicit month string" do
    expect(Billing::DraftMonthlyStatement).to receive(:call).with(month: Date.new(2026, 2, 1))
    described_class.perform_now("2026-02-15")
  end
end
