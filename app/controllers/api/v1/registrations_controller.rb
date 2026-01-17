class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :authenticate_request!, only: :create
  skip_before_action :ensure_active_user!, only: :create

  def create
    user = User.new(registration_params)

    user.save!

    token = JsonWebToken.encode(user_id: user.id)

    render_response({ user: user, token: token }, with: :session, status: :created)
  end

  private

  def registration_params
    params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
  end
end