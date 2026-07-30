class StorePolicy < ApplicationPolicy
  def show?
    return false unless owns_store?

    allows?(:store, :show)
  end

  def update?
    return false unless owns_store?

    allows?(:store, :update)
  end

  def destroy?
    return false unless owns_store?

    allows?(:store, :delete)
  end

  private

  def owns_store?
    record.is_a?(Store) && record.user_id == actor.id
  end
end
