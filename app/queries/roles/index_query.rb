class Roles::IndexQuery
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    base_scope
  end

  private

  def base_scope
    Role.where(store_id: @current_user.store_id)
  end
end