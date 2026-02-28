class ItemPolicy < ApplicationPolicy
  def index?
    allows?(:item, :index)
  end

  def show?
    return false unless same_store?
    return true if actor.global_permission.present?

    accessible_branch_ids = actor.branch_ids
    record.branches.exists?(id: accessible_branch_ids)
  end

  def create?
    return false unless same_store?

    allows?(:item, :create)
  end

  def update?
    return false unless same_store?
    return true if actor.global_permission.present?

    accessible_branch_ids = actor.branch_ids
    record.branches.exists?(id: accessible_branch_ids)
  end

  def destroy?
    return false unless same_store?
    return true if actor.global_permission.present?

    accessible_branch_ids = actor.branch_ids
    record.branches.exists?(id: accessible_branch_ids)
  end

  private

  def same_store?
    record.store_id == actor.store_id
  end
end
