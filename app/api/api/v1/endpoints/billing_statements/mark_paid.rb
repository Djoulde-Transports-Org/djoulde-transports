# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class MarkPaid < Grape::API
    helpers API::V1::Endpoints::BillingStatements::Common

    resource :billing_statements do
      route_param :id, type: Integer do
        desc "Mark an issued statement as paid."
        patch :mark_paid do
          authorize!(billing_statement, :mark_paid)
          billing_statement.update!(status: :paid)
          present billing_statement, with: ::API::V1::Entities::BillingStatement
        end
      end
    end
  end
end
