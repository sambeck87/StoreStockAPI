class Users::IndexQuery
  def initialize(current_user:, current_branch:, current_store:, params:)
    @current_user   = current_user
    @current_branch = current_branch
    @current_store  = current_store
    @params         = params
  end

  def call
    users = base_scope
    users = apply_filters(users)

    users
  end

  private

  def base_scope
    scope = User.where(store_id: @current_user.store_id)

    if @current_user.super_admin? and @current_user.store_id == @current_store&.id
      return @current_branch ? scope.for_branch(@current_branch) : scope
    end

    return User.none unless @current_branch

    scope.for_branch(@current_branch)
  end

  def apply_filters(scope)
    scope = scope.active   if @params[:active] == "true"
    scope = scope.inactive if @params[:active] == "false"

    scope
  end
end
