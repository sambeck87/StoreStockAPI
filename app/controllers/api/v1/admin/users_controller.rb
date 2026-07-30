class Api::V1::Admin::UsersController < ApplicationController
  wrap_parameters :user, include: %i[active branch_id role_id global_permission_id]

  def manage
    user = Users::FindAccessible.new(
      current_user: current_user,
      current_branch: nil,
      id: params[:id]
    ).call

    authorize!(user)

    Users::Manage.new(
      actor: current_user,
      user: user,
      params: manage_params
    ).call

    render_serialized(
      user,
      with: Api::V1::UserSerializer,
      view: :full
    )
  end

  def revoke_access
    user = Users::FindAccessible.new(
      current_user: current_user,
      current_branch: nil,
      id: params[:id]
    ).call

    branch_user = BranchUsers::FindAccessible.new(params: params).call

    authorize!(branch_user)

    branch_user.destroy!

    head :no_content
  end

  def detach_store
    user = Users::FindAccessible.new(
      current_user: current_user,
      current_branch: nil,
      id: params[:id]
    ).call

    authorize!(user)

    Users::DetachStore.new(
      actor: current_user,
      user: user
    ).call

    head :no_content
  end

  private

  def manage_params
    params.require(:user).permit(:active, :branch_id, :role_id, :global_permission_id)
  end
end
