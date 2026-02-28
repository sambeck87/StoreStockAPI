class Items::IndexQuery
  def initialize(current_user:, current_branch:, params:)
    @current_user = current_user
    @current_branch = current_branch
    @params = params
  end

  def call
    scope = base_scope
    apply_filters(scope)
  end

  private

  def base_scope
    Item.where(store_id: @current_user.store_id)
  end

  def apply_filters(scope)
    scope = scope.where(category_id: @params[:category_id]) if @params[:category_id].present?

    if @params[:branch_id].present?
      scope = scope.joins(:branch_items)
                   .where(branch_items: { branch_id: @params[:branch_id] })
    end

    scope = scope.where(active: @params[:active]) if @params[:active].present?

    scope
  end
end
