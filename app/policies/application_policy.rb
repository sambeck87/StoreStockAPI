class ApplicationPolicy
  def initialize(actor, record, branch:)
    @actor  = actor
    @record = record
    @branch = branch
  end

  private

  attr_reader :actor, :record, :branch

  def role
    @role ||= begin
      return actor.role_for_main_branch if actor.super_admin?
      return nil unless branch

      actor.role_for(branch)
    end
  end

  def allows?(resource, action)
    role&.allows?(resource, action)
  end

  def manage?
    role&.allows?(:user, :manage)
  end
end
