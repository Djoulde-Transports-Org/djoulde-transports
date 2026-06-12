# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class Issue < Grape::API
    helpers API::V1::Endpoints::BillingStatements::Common

    resource :billing_statements do
      route_param :id, type: Integer do
        desc "Issue a draft statement (sets issued_on and flips status to issued)."
        params do
          optional :issued_on, type: Date, documentation: {desc: "The date the statement was issued."}
        end
        patch :issue do
          authorize!(billing_statement, :issue)
          billing_statement.recalculate_total!
          billing_statement.update!(
            status: :issued,
            issued_on: params[:issued_on] || Time.zone.today
          )
          present billing_statement, with: ::API::V1::Entities::BillingStatement
        end
      end
    end
  end
end
