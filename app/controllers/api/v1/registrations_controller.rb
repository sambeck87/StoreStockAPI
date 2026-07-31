class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :authenticate_request!, only: :create
  skip_before_action :ensure_active_user!, only: :create

  def create
    user = User.new(registration_params)

    user.confirmation_token = SecureRandom.urlsafe_base64(48)
    user.confirmation_sent_at = Time.current

    user.save!

    ConfirmationMailer.confirmation(user).deliver_later

    render json: { message: I18n.t("registrations.create.success") }, status: :created
  end

  private

  def registration_params
    params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
  end
end
