# frozen_string_literal: true

module API::V1::Endpoints::BillingLineItems
  module Common
    extend Grape::API::Helpers

    def billing_line_item
      @billing_line_item ||= find_kept!(::BillingLineItem)
    end
  end
end
