class Api::V1::UserSerializer < BaseSerializer
  def initialize(user, context: {})
    @user = user
    @branch = context[:branch]
  end

  def compact
    {
      id: @user.id,
      full_name: @user.full_name,
      email: @user.email,
      active: @user.active,
      role: role_for_branch,
      branches: branches_without_roles
    }.compact
  end

  def full
    {
      id: @user.id,
      email: @user.email,
      full_name: @user.full_name,
      store_id: @user.store_id,
      global_permission: serialized_global_permission,
      branches: branches_with_roles,
      active: @user.active
    }
  end

  private

  def serialized_global_permission
    return nil unless @user.global_permission

    Api::V1::GlobalPermissionSerializer.new(@user.global_permission).compact
  end

  def branches_with_roles
    branch_users = @user.branch_users.includes(:branch, :role)
    branch_users.map do |branch_user|
      {
        id: branch_user.branch.id,
        name: branch_user.branch.name,
        role: branch_user.role && {
          id: branch_user.role.id,
          name: branch_user.role.name
        }
      }
    end
  end

  def branches_without_roles
    return nil if @branch
    @user.branch_users.map do |branch_user|
      branch = branch_user.branch
      next unless branch
      {
        id: branch.id,
        name: branch.name
      }
    end.compact
  end

  def role_for_branch
    return nil unless @branch

    branch_user = @user.branch_users.detect { |bu| bu.branch_id == @branch.id }
    return nil unless branch_user&.role

    {
      id: branch_user.role.id,
      name: branch_user.role.name
    }
  end
end
