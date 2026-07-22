class ItemPolicy < ApplicationPolicy
  def index?
    allows?(:item, :index)
  end

  def show?
    return false unless same_store?

    item_accessible?
  end

  def create?
    return false unless same_store?

    allows?(:item, :create)
  end

  def update?
    return false unless same_store?

    item_accessible? && allows?(:item, :update)
  end

  def destroy?
    return false unless same_store?

    item_accessible? && allows?(:item, :delete)
  end

  private

  def item_accessible?
    return true if actor.super_admin?

    accessible_ids = actor.branch_users.select(&:branch_id).map(&:branch_id)
    record_branch_ids = record.branch_items.map(&:branch_id)
    (accessible_ids & record_branch_ids).any?
  end

  def same_store?
    record.store_id == actor.store_id
  end
end
