class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_request!, only: :create

  def create
    user = User.find_by(email: params[:email])

    return render json: { error: "Invalid credentials" }, status: :unauthorized unless
      user&.authenticate(params[:password])

    token = JsonWebToken.encode(user_id: user.id)

    render json: Api::V1::SessionSerializer.new(user, token).full
  end
end
