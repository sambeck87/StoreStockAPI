class GlobalPermissionPolicy < ApplicationPolicy
  def index?
    allows?(:global_permission, :index)
  end

  def create?
    return false unless same_store? && actor.super_admin?

    allows?(:global_permission, :create)
  end

  def update?
    return false unless same_store?

    allows?(:global_permission, :update)
  end

  def destroy?
    return false unless same_store? && actor.super_admin?

    allows?(:global_permission, :delete)
  end

  private

  def same_store?
    record.store_id == actor.store_id
  end
end
