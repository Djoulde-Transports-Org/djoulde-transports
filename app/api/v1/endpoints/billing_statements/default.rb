# frozen_string_literal: true

module API::V1::Endpoints::BillingStatements
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::BillingStatements::List
    mount API::V1::Endpoints::BillingStatements::Create
    mount API::V1::Endpoints::BillingStatements::Generate
    mount API::V1::Endpoints::BillingStatements::Get
    mount API::V1::Endpoints::BillingStatements::Update
    mount API::V1::Endpoints::BillingStatements::Issue
    mount API::V1::Endpoints::BillingStatements::MarkPaid
    mount API::V1::Endpoints::BillingStatements::Delete
  end
end
