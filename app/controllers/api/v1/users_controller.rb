class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request!, only: :create

  def index
    users = User.all
    render_serialized(users, with: :user, view: :full, status: :ok)
  end

  def create
    user = User.new(user_params)

    if user.save
      token = JsonWebToken.encode(user_id: user.id)

      render_response({ user: user, token: token }, with: :session, status: :created)
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
  end
end
