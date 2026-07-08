# frozen_string_literal: true

module API::V1::Endpoints::BillingLineItems
  class List < Grape::API
    helpers do
      def base_billing_line_item_scope
        policy_scope(::BillingLineItem).order(started_on: :desc)
      end

      def billing_line_item_scope
        base_billing_line_item_scope
          .then { |s| params[:billing_statement_id] ? s.where(billing_statement_id: params[:billing_statement_id]) : s }
          .then { |s| params[:trip_id]              ? s.where(trip_id: params[:trip_id])                           : s }
      end
    end

    resource :billing_line_items do
      desc "List billing line items (kept only). Filter by billing_statement_id / trip_id."
      params do
        optional :billing_statement_id, type: Integer, documentation: {desc: "Filter line items by statement."}
        optional :trip_id,              type: Integer, documentation: {desc: "Filter line items by trip."}
      end
      get do
        authorize!(::BillingLineItem, :index)
        present billing_line_item_scope, with: ::API::V1::Entities::BillingLineItem
      end
    end
  end
end
