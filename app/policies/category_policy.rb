class CategoryPolicy < ApplicationPolicy
  def index?
    allows?(:category, :index) ||
    allows?(:category, :create) ||
    allows?(:category, :update) ||
    allows?(:category, :delete)
  end

  def show?
    return false unless same_store?

    allows?(:category, :show)
  end

  def create?
    return false unless same_store?

    allows?(:category, :create)
  end

  def update?
    return false unless same_store?

    allows?(:category, :update)
  end

  def destroy?
    return false unless same_store?

    allows?(:category, :delete)
  end

  private

  def same_store?
    record.store_id == actor.store_id
  end
end
