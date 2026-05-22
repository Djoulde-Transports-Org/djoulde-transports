# frozen_string_literal: true

# Billing line items are derived from trips by the monthly job and are
# read-only via the API.
class BillingLineItemPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
  end
end
