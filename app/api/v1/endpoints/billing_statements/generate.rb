# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class Generate < Grape::API
    resource :billing_statements do
      desc "Generate the draft statement for a month from its completed trips."
      params do
        requires :month, type: Date, documentation: {desc: "The month to generate the statement for."}
      end
      post "/generate" do
        authorize!(::BillingStatement, :create)
        present ::Billing::DraftMonthlyStatement.call(month: params[:month]), with: ::API::V1::Entities::BillingStatement
      end
    end
  end
end
