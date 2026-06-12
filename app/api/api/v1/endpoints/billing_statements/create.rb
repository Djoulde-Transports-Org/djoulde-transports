# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class Create < Grape::API
    helpers do
      def create_statement!
        month = params[:month].beginning_of_month
        attrs = {month: month}
        attrs[:number] = params[:number] if params[:number].present?
        attrs[:number] ||= format(::Billing::DraftMonthlyStatement::NumberFormat, year: month.year, month: month.month)
        ::BillingStatement.create!(attrs)
      end
    end

    resource :billing_statements do
      desc "Create a draft statement for a given month (the monthly job is the usual creator)."
      params do
        requires :month,  type: Date, documentation: {desc: "The month the statement covers."}
        optional :number, type: String, documentation: {desc: "An explicit statement number."}
      end
      post "/create" do
        authorize!(::BillingStatement, :create)
        present create_statement!, with: ::API::V1::Entities::BillingStatement
      end
    end
  end
end
