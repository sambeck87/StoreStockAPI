class Api::V1::BranchesController < ApplicationController
  before_action :set_branch, only: %i[show update destroy]

  def index
    authorize!(Branch)

    branches = Branches::IndexQuery.new(
      current_user: current_user,
      store: current_store
    ).call

    render_serialized(branches, with: :branch, view: :compact)
  end

  def show
    authorize!(@branch)

    render_serialized(@branch, with: :branch, view: :full)
  end

  def create
    branch = current_store.branches.new(branch_params.except(:manager_id))

    authorize!(branch)

    Branches::AssignManager.new(
      branch: branch,
      manager_id: branch_params[:manager_id]
    ).call

    branch.save!

    render_serialized(
      branch,
      with: :branch,
      view: :full,
      status: :created
    )
  end

  def update
    authorize!(@branch)

    Branches::AssignManager.new(
      branch: @branch,
      manager_id: branch_params[:manager_id]
    ).call

    @branch.update!(branch_params.except(:manager_id))

    render_serialized(@branch, with: :branch, view: :full)
  end

  def destroy
    authorize!(@branch)

    @branch.destroy!

    head :no_content
  end

  private
  def set_branch
    @branch = Branches::FindAccessible.new(
      current_user: current_user,
      store: current_store,
      id: params[:id]
    ).call
  end

  def branch_params
    params.require(:branch).permit(
      :name,
      :phone,
      :manager_id
    )
  end
end
