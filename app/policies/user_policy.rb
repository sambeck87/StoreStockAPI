class UserPolicy
  def initialize(actor, record, branch:)
    @actor = actor
    @record = record
    @branch = branch
  end

  def index?
    role&.allows?(:user, :read)
  end

  def show?
    return true if own_profile?
    return false unless @branch

    role&.allows?(:user, :read)
  end

  def create?
    role&.allows?(:user, :create)
  end

  def update?
    return true if own_profile?
    return false unless @branch

    role&.allows?(:user, :update)
  end

  def destroy?
    role&.allows?(:user, :delete)
  end

  private

  def own_profile?
    @actor.id == @record.id
  end

  def role
    @user.role_for(@branch)
  end
end
