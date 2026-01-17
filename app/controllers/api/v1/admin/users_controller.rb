class Api::V1::Admin::UsersController < ApplicationController
  def update
    user = Users::FindAccessible.new(
      current_user: current_user,
      current_branch: nil,
      id: params[:id]
    ).call

    authorize!(user, :manage?)

    Users::Manage.new(
      actor: current_user,
      user: user,
      params: manage_params
    ).call

    render_serialized(user, with: :user, view: :full)
  end

  private

  def manage_params
    params.require(:user).permit(:active, :branch_id, :role_id)
  end
end
