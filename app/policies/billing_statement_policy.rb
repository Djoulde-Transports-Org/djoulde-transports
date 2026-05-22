# frozen_string_literal: true

class BillingStatementPolicy < ApplicationPolicy
  def issue?
    super_admin?
  end

  def mark_paid?
    super_admin?
  end

  class Scope < ApplicationPolicy::Scope
  end
end
