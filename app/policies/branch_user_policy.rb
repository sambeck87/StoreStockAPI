class BranchUserPolicy < ApplicationPolicy
  def revoke_access?
    return false unless actor.super_admin?
    return false unless record.branch.store.user_id == actor.id

    allows?(:user, :revoke_access)
  end
end
