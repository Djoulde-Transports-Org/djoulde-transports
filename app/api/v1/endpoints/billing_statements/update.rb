# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class Update < Grape::API
    helpers API::V1::Endpoints::BillingStatements::Common

    helpers do
      def update_statement!
        billing_statement.update!(billing_statement_params)
        billing_statement
      end
    end

    resource :billing_statements do
      route_param :id, type: Integer do
        desc "Update a draft statement's metadata."
        params do
          optional :number,    type: String, documentation: {desc: "The statement number."}
          optional :issued_on, type: Date, documentation: {desc: "The date the statement was issued."}
          optional :due_on,    type: Date, documentation: {desc: "The date payment is due."}
        end
        patch "/update" do
          authorize!(billing_statement, :update)
          present update_statement!, with: ::API::V1::Entities::BillingStatement
        end
      end
    end
  end
end
