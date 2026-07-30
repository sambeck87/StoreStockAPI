class Api::V1::InventoryController < ApplicationController
  include Paginatable

  def index
    authorize!(Item)

    scope = Items::InventoryQuery.new(
      current_user: current_user,
      params: index_params
    ).call

    records, meta = paginate(scope, **pagination_params)

    render json: { items: build_rows(records), meta: meta }, status: :ok
  end

  private

  def index_params
    params.permit(:branch_id, :category_id, :active, :quantity_status, :page, :per_page)
  end

  def build_rows(items)
    items.map do |item|
      row = {
        id: item.id,
        name: item.name,
        measure: item.measure,
        cost: item.cost.to_f,
        category_id: item.category_id,
        category_name: item.category&.name
      }

      if item.respond_to?(:inventory_bi_id) && item.inventory_bi_id.present?
        row[:branch_id] = item.inventory_branch_id
        row[:branch_name] = item.inventory_branch_name
        row[:current_quantity] = item.inventory_quantity
        row[:minimum_quantity] = item.inventory_minimum
        row[:active] = item.inventory_active
        row[:quantity_status] = compute_quantity_status(
          item.inventory_quantity, item.inventory_minimum
        )
      else
        row[:active] = item.active
      end

      row
    end
  end

  def compute_quantity_status(quantity, minimum)
    return "empty" if quantity.nil? || quantity <= 0

    if minimum.present? && quantity < minimum
      "low"
    else
      "complete"
    end
  end
end
