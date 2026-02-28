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
      active: @item.active,
      current_quantity: branch_item&.current_quantity,
      minimum_quantity: branch_item&.minimum_quantity
    }
  end

  def full
    {
      id: @item.id,
      name: @item.name,
      measure: @item.measure,
      cost: @item.cost,
      active: @item.active,
      category_id: @item.category_id,
      updated_by: @item.updated_by&.full_name,
      created_by: @item.created_by&.full_name,
      current_quantity: branch_item&.current_quantity,
      minimum_quantity: branch_item&.minimum_quantity
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
end
