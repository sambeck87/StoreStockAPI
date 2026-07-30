class BranchPolicy < ApplicationPolicy
  def show?
    return false unless record.branch_users.any? { |bu| bu.user_id == actor.id }

    allows?(:branch, :show)
  end

  def create?
    return false unless actor.super_admin?
    return false unless owns_store?

    allows?(:branch, :create)
  end

  def update?
    return false unless owns_store?

    allows?(:branch, :update)
  end

  def destroy?
    return false unless actor.super_admin?
    return false unless owns_store?

    allows?(:branch, :delete)
  end

  def owns_store?
    record.store_id == actor.store_id
  end
end
