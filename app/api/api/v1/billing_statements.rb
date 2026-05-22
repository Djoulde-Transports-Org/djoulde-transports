# frozen_string_literal: true

module API::V1
  class BillingStatements < Grape::API
    before { authenticate! }

    resource :billing_statements do
      desc "List billing statements (kept only)."
      params do
        optional :status, type: String, values: ::BillingStatement.statuses.keys
      end
      get do
        authorize!(::BillingStatement, :index)
        scope = policy_scope(::BillingStatement).order(month: :desc)
        scope = scope.where(status: ::BillingStatement.statuses[params[:status]]) if params[:status]
        present scope, with: API::V1::Entities::BillingStatement
      end

      desc "Create a draft statement for a given month (the monthly job is the usual creator)."
      params do
        requires :month,  type: Date
        optional :number, type: String
      end
      post do
        authorize!(::BillingStatement, :create)
        month = params[:month].beginning_of_month
        attrs = {month: month}
        attrs[:number] = params[:number] if params[:number].present?
        attrs[:number] ||= format(Billing::DraftMonthlyStatement::NumberFormat, year: month.year, month: month.month)
        statement = ::BillingStatement.create!(attrs)
        present statement, with: API::V1::Entities::BillingStatement
      end

      route_param :id, type: Integer do
        desc "Get a billing statement."
        get do
          statement = find_kept!(::BillingStatement)
          authorize!(statement, :show)
          present statement, with: API::V1::Entities::BillingStatement
        end

        desc "Update a draft statement's metadata."
        params do
          optional :number,    type: String
          optional :issued_on, type: Date
          optional :due_on,    type: Date
        end
        patch do
          statement = find_kept!(::BillingStatement)
          authorize!(statement, :update)
          statement.update!(declared(params, include_missing: false).except(:id))
          present statement, with: API::V1::Entities::BillingStatement
        end

        desc "Issue a draft statement (sets issued_on and flips status to issued)."
        params do
          optional :issued_on, type: Date
        end
        patch :issue do
          statement = find_kept!(::BillingStatement)
          authorize!(statement, :issue)
          statement.recalculate_total!
          statement.update!(
            status: :issued,
            issued_on: params[:issued_on] || Time.zone.today
          )
          present statement, with: API::V1::Entities::BillingStatement
        end

        desc "Mark an issued statement as paid."
        patch :mark_paid do
          statement = find_kept!(::BillingStatement)
          authorize!(statement, :mark_paid)
          statement.update!(status: :paid)
          present statement, with: API::V1::Entities::BillingStatement
        end

        desc "Soft-delete a statement (blocked when kept line items exist)."
        delete do
          statement = find_kept!(::BillingStatement)
          authorize!(statement, :destroy)
          begin
            ::BillingStatements::Discard.call(statement)
          rescue ApplicationService::HasDependents => error
            unprocessable!(error.message, code: "has_dependents")
          end
          status 204
          body false
        end
      end
    end
  end
end
