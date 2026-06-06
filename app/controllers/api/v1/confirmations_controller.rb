class Api::V1::ConfirmationsController < ApplicationController
  skip_before_action :authenticate_request!
  skip_before_action :ensure_active_user!

  def update
    user = User.find_by(confirmation_token: params[:id])

    return render json: { error: "Token inválido" }, status: :not_found unless user

    user.update(
      confirmation_token: nil,
      confirmed_at: Time.current
    )

    render json: { message: "Correo confirmado exitosamente" }
  end
end