class Branches::FindAccessible
  def initialize(current_user:, store:, id:)
    @current_user = current_user
    @store        = store
    @id           = id
  end

  def call
    base_scope.find(@id)
  end

  private

  def base_scope
    scope = @store.branches.includes(:manager)

    return scope if @current_user.super_admin?

    scope.joins(:branch_users)
         .where(branch_users: { user_id: @current_user.id })
  end
end
