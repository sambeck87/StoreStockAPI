class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: %i[show update destroy]

  def index
    authorize!(Category)

    categories = Categories::IndexQuery.new(
      current_user: current_user,
      current_branch: current_branch,
      params: params
    ).call

    render_serialized(
      categories,
      with: :category,
      view: :compact,
      status: :ok
    )
  end

  def show
    authorize!(@category)

    render_serialized(
      @category,
      with: :category,
      view: :full
    )
  end

  def create
    category = Categories::CreateCategory.new(
      user: current_user,
      params: category_params
    ).call

    authorize!(category)

    category.save!

    render_serialized(
      category,
      with: :category,
      view: :full,
      status: :created
    )
  end

  def update
    authorize!(@category)

    @category.update!(category_params.merge(updated_by: current_user))

    render_serialized(
      @category,
      with: :category,
      view: :full
    )
  end

  def destroy
    authorize!(@category)

    @category.destroy!

    head :no_content
  end

  private

  def set_category
    @category = Categories::FindAccessible.new(
      current_user: current_user,
      params: params
    ).call
  end

  def category_params
    params.require(:category).permit(:name, :active)
  end
end
