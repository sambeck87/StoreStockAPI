class RolePolicy < ApplicationPolicy
  def index?
    allows?(:role, :index)
  end

  def create?
    return false unless actor.super_admin?

    allows?(:role, :create)
  end

  def update?
    allows?(:role, :update)
  end

  def destroy?
    return false unless actor.super_admin?

    allows?(:role, :delete)
  end
end
