# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class List < Grape::API
    helpers do
      def base_billing_statement_scope
        policy_scope(::BillingStatement).order(month: :desc)
      end

      def billing_statement_scope
        base_billing_statement_scope
          .then { |s| params[:status] ? s.where(status: ::BillingStatement.statuses[params[:status]]) : s }
      end
    end

    resource :billing_statements do
      desc "List billing statements (kept only)."
      params do
        optional :status, type: String, values: ::BillingStatement.statuses.keys, documentation: {desc: "Filter statements by status."}
      end
      get do
        authorize!(::BillingStatement, :index)
        present billing_statement_scope, with: ::API::V1::Entities::BillingStatement
      end
    end
  end
end
