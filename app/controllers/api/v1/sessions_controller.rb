class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_request!, only: :create
  skip_before_action :ensure_active_user!, only: :create

  def create
    user = User.find_by(email: params[:email])

    raise AuthenticationError unless user&.authenticate(params[:password])
    raise UnconfirmedEmailError if user.confirmation_token.present?

    token = JsonWebToken.encode(user_id: user.id)

    render_response({ user: user, token: token }, with: :session, status: :created)
  end
end
