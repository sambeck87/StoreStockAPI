class Api::V1::UsersController < ApplicationController
  skip_before_action :ensure_active_user!, only: %i[show update destroy]
  before_action :set_user, only: %i[show update destroy]

  def index
    authorize!(User)

    users = Users::IndexQuery.new(
      current_user: current_user,
      current_branch: current_branch,
      current_store: current_store,
      params: params
    ).call

    render_serialized(users, with: :user, view: :compact, status: :ok)
  end

  def show
    authorize!(@user)

    render_serialized(@user, with: :user, view: :full, status: :ok)
  end

  def update
    authorize!(@user)

    Users::AssignStore.new(
      user: @user,
      store_id: user_params[:store_id]
    ).call

    @user.update!(user_params.except(:store_id))

    render_serialized(@user, with: :user, view: :full)
  end

  def destroy
    authorize!(@user)

    Users::EnsureDeletable.new(user: @user).call

    @user.destroy!

    head :no_content
  end

  private
  def set_user
    @user = Users::FindAccessible.new(
      current_user: current_user,
      current_branch: current_branch,
      id: params[:id]
    ).call
  end

  def user_params
    params.require(:user).permit(:email, :full_name, :store_id)
  end
end
