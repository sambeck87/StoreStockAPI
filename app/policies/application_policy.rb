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
      return actor_role_for_main_branch if actor.super_admin?
      return nil unless branch.present?

      actor_role_for_branch
    end
  end

  def actor_role_for_main_branch
    main_bu = actor.branch_users.detect { |bu| bu.branch&.is_main }
    main_bu&.role
  end

  def actor_role_for_branch
    bu = actor.branch_users.detect { |b| b.branch_id == branch&.id }
    bu&.role
  end

  def allows?(resource, action)
    return true if global_allows?(resource, action)

    return true if role&.allows?(resource, action)

    return true if branchless_allows?(resource, action)

    false
  end

  def branchless_allows?(resource, action)
    return false unless branch.nil?
    return false if actor.super_admin?

    accessible_branch_ids = actor.branch_ids_with_permission(resource, action)
    accessible_branch_ids.any?
  end

  def global_allows?(resource, action)
    actor.global_permission&.allows?(resource, action) || false
  end
end
