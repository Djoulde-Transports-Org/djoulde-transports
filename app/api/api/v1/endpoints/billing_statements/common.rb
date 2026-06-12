# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  module Common
    extend Grape::API::Helpers

    def billing_statement
      @billing_statement ||= find_kept!(::BillingStatement)
    end

    def billing_statement_params
      declared(params, include_missing: false).except(:id)
    end
  end
end
