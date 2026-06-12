# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class Delete < Grape::API
    helpers API::V1::Endpoints::BillingStatements::Common

    resource :billing_statements do
      route_param :id, type: Integer do
        desc "Soft-delete a statement (blocked when kept line items exist)."
        delete "/delete" do
          authorize!(billing_statement, :destroy)
          result =
            begin
              ::BillingStatements::Discard.call(billing_statement)
            rescue ApplicationService::HasDependents => error
              unprocessable!(error.message, code: "has_dependents")
            end
          present result, with: ::API::V1::Entities::DeleteResult
        end
      end
    end
  end
end
