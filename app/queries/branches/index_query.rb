class Branches::IndexQuery
  def initialize(current_user:, store:)
    @current_user = current_user
    @store        = store
  end

  def call
    base_scope
  end

  private

  def base_scope
    stores = @store.branches.where(store_id: @current_user.store_id)
    return stores if @current_user.super_admin?

    stores.joins(:branch_users)
          .where(branch_users: { user_id: @current_user.id })
  end
end