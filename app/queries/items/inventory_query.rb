class Items::InventoryQuery
  def initialize(current_user:, params:)
    @current_user = current_user
    @params = params
  end

  def call
    branch_ids = accessible_branch_ids
    return Item.none if branch_ids.empty?

    scope = Item.where(store_id: @current_user.store_id)
                .includes(:category)

    scope = scope.where(category_id: @params[:category_id]) if @params[:category_id].present?

    if @params[:active].present? && @params[:active] != "all"
      scope = scope.where(branch_items: { active: @params[:active] })
    end

    scope = scope.joins(:branch_items)
                 .where(branch_items: { branch_id: branch_ids })

    if @params[:quantity_status].present?
      scope = case @params[:quantity_status]
      when "complete"
                scope.where(
                  "branch_items.current_quantity > 0 AND (branch_items.minimum_quantity IS NULL OR branch_items.current_quantity >= branch_items.minimum_quantity)"
                )
      when "low"
                scope.where(
                  "branch_items.current_quantity > 0 AND branch_items.minimum_quantity IS NOT NULL AND branch_items.current_quantity < branch_items.minimum_quantity"
                )
      when "empty"
                scope.where("branch_items.current_quantity IS NULL OR branch_items.current_quantity <= 0")
      else
                scope
      end
    end

    scope = scope.joins("INNER JOIN branches ON branches.id = branch_items.branch_id")
                 .select(
                   "items.*",
                    "branch_items.id AS inventory_bi_id",
                    "branch_items.branch_id AS inventory_branch_id",
                    "branch_items.current_quantity AS inventory_quantity",
                    "branch_items.minimum_quantity AS inventory_minimum",
                    "branch_items.active AS inventory_active",
                   "branches.name AS inventory_branch_name"
                 )
                 .order(
                   Arel.sql(
                     "branches.name ASC, " \
                     "CASE " \
                     "  WHEN COALESCE(branch_items.current_quantity, 0) <= 0 THEN 0 " \
                     "  WHEN branch_items.current_quantity < COALESCE(branch_items.minimum_quantity, 0) THEN 1 " \
                     "  ELSE 2 " \
                     "END ASC, " \
                     "items.name ASC"
                   )
                 )

    scope
  end

  private

  def accessible_branch_ids
    all_accessible = @current_user.branch_users.map(&:branch_id)
    return [] if all_accessible.empty?

    if @params[:branch_id].present?
      id = @params[:branch_id].to_i
      all_accessible.include?(id) ? [ id ] : []
    else
      all_accessible
    end
  end
end
