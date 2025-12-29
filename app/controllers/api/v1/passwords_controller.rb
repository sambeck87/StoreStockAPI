class Api::V1::PasswordsController < ApplicationController
  skip_before_action :authenticate_request!, only: %i[reset update]

  def reset
    user = User.find_by(email: params[:email])
    PasswordsMailer.reset(user).deliver_later if user
    head :no_content
  end

  def update
    user = User.find_by(reset_password_token: params[:token])

    raise InvalidTokenError unless user

    if user.update(
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      reset_password_token: nil
    )
      head :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
