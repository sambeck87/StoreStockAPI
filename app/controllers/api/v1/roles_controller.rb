class Api::V1::RolesController < ApplicationController
  before_action :set_role, only: %i[show update destroy]

  def index
    authorize!(Role)

    roles = Roles::IndexQuery.new(
      current_user: current_user,
    ).call

    render_serialized(
      roles,
      view: :full
      )
  end

  def show
    render_serialized(
      @role,
      view: :full
    )
  end

  def create
    role = current_store.roles.new(role_params)

    authorize!(role)

    role.save!

    render_serialized(
      role,
      view: :full,
      status: :created
    )
  end

  def update
    authorize!(@role)

    @role.update!(role_params)

    render_serialized(
      @role,
      view: :full,
      status: :ok
    )
  end

  def destroy
    authorize!(@role)

    @role.destroy!

    head :no_content
  end

  private

  def set_role
    @role = Roles::FindAccessible.new(
      current_user: current_user,
      params: params
    ).call
  end

  def role_params
    params.require(:role).permit(:name, permissions: {})
  end
end
