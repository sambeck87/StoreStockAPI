class BranchPolicy < ApplicationPolicy
  def index?
    allows?(:branch, :index)
  end

  def show?
    return true if actor.super_admin?

    record.users.exists?(actor.id)
  end

  def create?
    return false unless owns_store?

    actor.super_admin?
  end

  def update?
    return false unless owns_store?

    actor.super_admin? || record.manager_id == actor.id
  end

  def destroy?
    actor.super_admin?
  end

  def owns_store?
    record.store_id == actor.store_id
  end
end
