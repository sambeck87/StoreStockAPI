class GlobalPermissions::IndexQuery
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    base_scope
  end

  private

  def base_scope
    GlobalPermission.where(store_id: @current_user.store_id)
  end
end