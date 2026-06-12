# frozen_string_literal: true

# Read-only API: billing line items are produced by `Billing::DraftMonthlyStatement`
# and snapshotted via `BillingLineItem.from_trip`.
module API::V1::Endpoints::BillingLineItems
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::BillingLineItems::List
    mount API::V1::Endpoints::BillingLineItems::Get
  end
end
