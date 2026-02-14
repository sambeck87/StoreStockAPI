class Api::V1::GlobalPermissionsController < ApplicationController
  before_action :set_global_permission, only: %i[show update destroy]

  def index
    authorize!(GlobalPermission)

    global_permissions = GlobalPermissions::IndexQuery.new(
      current_user: current_user,
    ).call

    render_serialized( global_permissions )
  end

  def show
    authorize!(@global_permission)

    render_serialized(
      @global_permission,
      view: :full
    )
  end

  def create
    global_permission = current_store.global_permissions.new(global_permission_params)

    authorize!(global_permission)

    global_permission.save!
    render_serialized(
      global_permission,
      view: :full,
      status: :created
    )
  end

  def update
    authorize!(@global_permission)

    @global_permission.update!(global_permission_params)

    render_serialized(
      @global_permission,
      view: :full,
      status: :ok
    )
  end

  def destroy
    authorize!(@global_permission)

    @global_permission.destroy!

    head :no_content
  end

  private

  def set_global_permission
    @global_permission = GlobalPermissions::FindAccessible.new(
      current_user: current_user,
      params: params
    ).call
  end

  def global_permission_params
    params.require(:global_permission).permit(:name, permissions: {})
  end
end
