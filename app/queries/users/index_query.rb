class Users::IndexQuery
  def initialize(current_user:, current_branch:, params:)
    @current_user   = current_user
    @current_branch = current_branch
    @params         = params
  end

  def call
    users = base_scope
    users = apply_filters(users)

    users
  end

  private

  def base_scope
    scope = User
      .where(store_id: @current_user.store_id)
      .includes(:global_permission, branch_users: [ :role, :branch ])

    if @current_user.has_global_permission?(:user, :index)
      if @params[:branch_id].present?
        return scope.for_branch_id(@params[:branch_id].to_i)
      end
      return scope
    end

    accessible_branch_ids = @current_user.branch_ids_with_permission(:user, :index)
    return User.none if accessible_branch_ids.empty?

    if @params[:branch_id].present?
      branch_id = @params[:branch_id].to_i
      return User.none unless accessible_branch_ids.include?(branch_id)
      return scope.for_branch_id(branch_id)
    end

    scope.for_branches(accessible_branch_ids)
  end

  def apply_filters(scope)
    scope = scope.active   if @params[:active] == "true"
    scope = scope.inactive if @params[:active] == "false"

    scope
  end
end
