class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request!, only: :create

  def index
    users = User.all
    render_resource(:users, serialize(users, with: :user))
  end

  def create
    user = User.new(user_params)

    if user.save
      token = JsonWebToken.encode(user_id: user.id)

      render json: {
        token: token,
        expires_in: 24.hours.to_i,
        user: {
          id: user.id,
          email: user.email
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
  end
end
