class Api::V1::ItemsController < ApplicationController
  wrap_parameters :item, include: %i[name measure cost active category_id branch_id current_quantity minimum_quantity]

  before_action :set_item, only: %i[show update destroy]
  before_action :set_category, only: %i[create]

  def index
    authorize!(Item)

    items = Items::IndexQuery.new(
      current_user: current_user,
      current_branch: current_branch,
      params: index_params
    ).call

    render_serialized(
      items,
      with: :item,
      view: :compact,
      current_branch: current_branch,
      status: :ok
    )
  end

  def show
    authorize!(@item)

    render_serialized(
      @item,
      with: :item,
      view: :full,
      current_branch: current_branch,
      status: :ok
    )
  end

  def create
    item_transaction = Items::CreateItem.new(
      user: current_user,
      params: item_params,
      current_branch: current_branch,
      current_category: @category
    ).call

    authorize!(item_transaction.item)

    item_transaction.save!

    render_serialized(
      item_transaction.item,
      with: :item,
      view: :full,
      current_branch: current_branch,
      status: :created
    )
  end

  def update
    authorize!(@item)

    ActiveRecord::Base.transaction do
      Items::UpdateItem.new(
        item: @item,
        user: current_user,
        item_params: item_params,
        branch_id: params[:branch_id]
      ).call
    end

    render_serialized(
      @item,
      with: :item,
      view: :full,
      current_branch: current_branch,
      status: :ok
    )
  end

  def destroy
    authorize!(@item)

    @item.destroy!

    head :no_content
  end

  private

  def set_item
    @item = Items::FindAccessible.new(
      current_user: current_user,
      params: params
    ).call
  end

  def set_category
    return @category = nil unless params[:category_id].present?

    @category = current_user.store.categories.find(params[:category_id])
  rescue ActiveRecord::RecordNotFound
    raise NotFoundError
  end

  def index_params
    params.permit(:category_id, :branch_id, :active)
  end

  def item_params
    params.require(:item).permit(:name, :measure, :cost, :active, :category_id, :branch_id, :current_quantity, :minimum_quantity)
  end
end
