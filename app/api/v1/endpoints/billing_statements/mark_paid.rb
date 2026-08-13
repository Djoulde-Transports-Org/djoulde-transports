# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class MarkPaid < Grape::API
    helpers API::V1::Endpoints::BillingStatements::Common

    resource :billing_statements do
      route_param :id, type: Integer do
        desc "Mark an issued statement as paid."
        params do
          optional :paid_on, type: Date, documentation: {desc: "The date payment was completed."}
        end
        patch :mark_paid do
          authorize!(billing_statement, :mark_paid)
          billing_statement.update!(status: :paid, paid_on: params[:paid_on] || Time.zone.today)
          present billing_statement, with: ::API::V1::Entities::BillingStatement
        end
      end
    end
  end
end
