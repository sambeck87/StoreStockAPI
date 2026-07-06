class Categories::IndexQuery
  def initialize(current_user:, current_branch:, params:)
    @current_user = current_user
    @params = params
  end

  def call
    scope = base_scope
    scope = apply_filters(scope)
    scope.order(:name)
  end

  private

  def base_scope
    Category.where(store_id: @current_user.store_id)
  end

  def apply_filters(scope)
    scope = scope.by_name(@params[:name]) if @params[:name].present?
    scope
  end
end