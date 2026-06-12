# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class List < Grape::API
    resource :billing_statements do
      desc "List billing statements (kept only)."
      params do
        optional :status, type: String, values: ::BillingStatement.statuses.keys, documentation: {desc: "Filter statements by status."}
      end
      get do
        authorize!(::BillingStatement, :index)
        scope = policy_scope(::BillingStatement).order(month: :desc)
        scope = scope.where(status: ::BillingStatement.statuses[params[:status]]) if params[:status]
        present scope, with: ::API::V1::Entities::BillingStatement
      end
    end
  end
end
