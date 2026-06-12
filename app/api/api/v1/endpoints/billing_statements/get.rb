# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class Get < Grape::API
    helpers API::V1::Endpoints::BillingStatements::Common

    resource :billing_statements do
      route_param :id, type: Integer do
        desc "Get a billing statement."
        get do
          authorize!(billing_statement, :show)
          present billing_statement, with: ::API::V1::Entities::BillingStatement
        end
      end
    end
  end
end
