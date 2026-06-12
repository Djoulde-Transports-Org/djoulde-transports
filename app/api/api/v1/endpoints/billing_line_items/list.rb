# frozen_string_literal: true

module API::V1::Endpoints::BillingLineItems
  class List < Grape::API
    resource :billing_line_items do
      desc "List billing line items (kept only). Filter by billing_statement_id / trip_id."
      params do
        optional :billing_statement_id, type: Integer, documentation: {desc: "Filter line items by statement."}
        optional :trip_id,              type: Integer, documentation: {desc: "Filter line items by trip."}
      end
      get do
        authorize!(::BillingLineItem, :index)
        scope = policy_scope(::BillingLineItem).order(started_on: :desc)
        scope = scope.where(billing_statement_id: params[:billing_statement_id]) if params[:billing_statement_id]
        scope = scope.where(trip_id: params[:trip_id])                           if params[:trip_id]
        present scope, with: ::API::V1::Entities::BillingLineItem
      end
    end
  end
end
