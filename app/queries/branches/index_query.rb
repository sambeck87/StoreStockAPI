class Branches::IndexQuery
  def initialize(current_user:, store:)
    @current_user = current_user
    @store        = store
  end

  def call
    base_scope = base_scope.includes(:manager)

    return base_scope if @current_user.super_admin?

    base_scope
      .joins(:branch_users)
      .where(branch_users: { user_id: @current_user.id })
      .distinct
  end

  private

  def base_scope
    @store.branches
  end
end