# frozen_string_literal: true

# Read-only API: billing line items are produced by `Billing::DraftMonthlyStatement`
# and snapshotted via `BillingLineItem.from_trip`.
module API::V1
  class BillingLineItems < Grape::API
    before { authenticate! }

    resource :billing_line_items do
      desc "List billing line items (kept only). Filter by billing_statement_id / trip_id."
      params do
        optional :billing_statement_id, type: Integer
        optional :trip_id,              type: Integer
      end
      get do
        authorize!(::BillingLineItem, :index)
        scope = policy_scope(::BillingLineItem).order(started_on: :desc)
        scope = scope.where(billing_statement_id: params[:billing_statement_id]) if params[:billing_statement_id]
        scope = scope.where(trip_id: params[:trip_id]) if params[:trip_id]
        present scope, with: API::V1::Entities::BillingLineItem
      end

      route_param :id, type: Integer do
        desc "Get a billing line item."
        get do
          line_item = find_kept!(::BillingLineItem)
          authorize!(line_item, :show)
          present line_item, with: API::V1::Entities::BillingLineItem
        end
      end
    end
  end
end
