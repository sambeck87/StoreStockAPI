class Api::V1::ItemSerializer < BaseSerializer
  def initialize(item, current_branch: nil)
    @item = item
    @current_branch = current_branch
  end

  def compact
    {
      id: @item.id,
      name: @item.name,
      measure: @item.measure,
      cost: @item.cost.to_f,
      active: branch_item&.active.nil? ? @item.active : branch_item.active,
      current_quantity: branch_item&.current_quantity,
      minimum_quantity: branch_item&.minimum_quantity,
      quantity_status: computed_quantity_status
    }
  end

  def full
    {
      id: @item.id,
      name: @item.name,
      measure: @item.measure,
      cost: @item.cost.to_f,
      active: branch_item&.active.nil? ? @item.active : branch_item.active,
      category_id: @item.category_id,
      updated_by: @item.updated_by&.full_name,
      created_by: @item.created_by&.full_name,
      current_quantity: branch_item&.current_quantity,
      minimum_quantity: branch_item&.minimum_quantity,
      quantity_status: computed_quantity_status
    }
  end

  private

  def branch_item
    return @branch_item if defined?(@branch_item)

    @branch_item = if @current_branch.present?
                     @item.branch_items.find_by(branch_id: @current_branch.id)
    else
                     @item.branch_items.first
    end
  end

  def computed_quantity_status
    quantity = branch_item&.current_quantity
    minimum = branch_item&.minimum_quantity

    return "empty" if quantity.nil? || quantity <= 0

    if minimum.present? && quantity < minimum
      "low"
    else
      "complete"
    end
  end
end
