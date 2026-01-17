class UserPolicy < ApplicationPolicy
  def index?
    allows?(:user, :index)
  end

  def show?
    return true if own_profile?

    allows?(:user, :show)
  end

  def create?
    allows?(:user, :create)
  end

  def update?
    return true if own_profile?

    allows?(:user, :update)
  end

  def destroy?
    return true if own_profile?

    allows?(:user, :delete)
  end

  private

  def own_profile?
    record.is_a?(User) && actor.id == record.id
  end
end
