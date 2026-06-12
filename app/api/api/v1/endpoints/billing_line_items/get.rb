# frozen_string_literal: true

module API::V1::Endpoints::BillingLineItems
  class Get < Grape::API
    helpers API::V1::Endpoints::BillingLineItems::Common

    resource :billing_line_items do
      route_param :id, type: Integer do
        desc "Get a billing line item."
        get do
          authorize!(billing_line_item, :show)
          present billing_line_item, with: ::API::V1::Entities::BillingLineItem
        end
      end
    end
  end
end
