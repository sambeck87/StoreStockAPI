class Stores::FindAccessible
  def initialize(current_user:, params:)
    @current_user = current_user
    @params       = params
  end

  def call
    scope = base_scope
    scope = filter_by_id(scope)
    scope = apply_filters(scope)
    scope
  end

  private

  def base_scope
    Store.all
  end

  def filter_by_id(scope)
    return scope unless @params[:id].present?

    if @current_user.super_admin?
      scope.where(id: @params[:id])
    else
      scope.where(id: @params[:id], user_id: @current_user.id)
    end
  end

  def apply_filters(scope)
    scope = scope.where("stores.name LIKE ?", "%#{@params[:name]}%") if @params[:name].present?

    scope = scope.joins(:user)
            .where("users.full_name LIKE ?", "%#{@params[:manager]}%") if @params[:manager].present?

    scope
  end
end
