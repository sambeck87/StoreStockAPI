class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request!, only: :create

  def index
    authorize!(User)
    users = User.all

    render_serialized(users, with: :user, view: :full, status: :ok)
  end

  def show
    user = find_resource(User)

    authorize!(user)

    render_serialized(user, with: :user, view: :full, status: :ok)
  end

  def create
    user = User.new(user_params)

    user.save!

    token = JsonWebToken.encode(user_id: user.id)

    render_response({ user: user, token: token }, with: :session, status: :created)
  rescue ActiveRecord::RecordInvalid => e
    raise ValidationError.new(e.record)
  end

  def update
    current_user.update!(user_params)
  end

  def destroy
    current_user.destroy!
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
  end
end
