# frozen_string_literal: true

# Baseline policy for ticket 11 (Grape API v1).
#
# Authenticated users can read; only `super_admin` can mutate. Ticket 14 will
# narrow per role (dispatcher / billing / maintenance / driver_readonly).
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user   = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    super_admin?
  end

  def new?
    create?
  end

  def update?
    super_admin?
  end

  def edit?
    update?
  end

  def destroy?
    super_admin?
  end

  private

  def super_admin?
    user&.has_role?(:super_admin)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      scope.kept
    end

    private

    def super_admin?
      user&.has_role?(:super_admin)
    end
  end
end
