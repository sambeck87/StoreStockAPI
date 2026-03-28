class Users::FindAccessible
  def initialize(current_user:, current_branch:, id:)
    @current_user   = current_user
    @current_branch = current_branch
    @id             = id
  end

  def call
    base_scope.find(@id)
  end

  private

  def base_scope
    scope = User.all.includes(:global_permission, branch_users: :role)

    return scope if @current_user.super_admin?
    return scope.where(store_id: @current_user.store_id) if @current_user.store_id.present?

    return User.none unless @current_branch

    scope.for_branch(@current_branch)
  end
end
