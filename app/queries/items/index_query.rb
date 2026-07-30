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
        .includes(:category, :branch_items)
  end

  def apply_filters(scope)
    scope = scope.where(category_id: @params[:category_id]) if @params[:category_id].present?

    if @params[:branch_id].present?
      scope = scope.joins(:branch_items)
                   .where(branch_items: { branch_id: @params[:branch_id] })

      if @params[:active].present?
        scope = scope.where(branch_items: { active: @params[:active] })
      end
    elsif @params[:active].present?
      scope = scope.where(active: @params[:active])
    end

    scope.order(:name)
  end
end
