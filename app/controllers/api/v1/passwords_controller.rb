class Api::V1::PasswordsController < ApplicationController
  skip_before_action :authenticate_request!, only: %i[reset update confirm_email]
  skip_before_action :ensure_active_user!, only: %i[reset update confirm_email]
  before_action :validate_reset_token, only: :update

  def reset
    user = User.find_by(email: params[:email])

    if user
      user.update!(
        reset_password_token: SecureRandom.urlsafe_base64(48),
        reset_password_sent_at: Time.current
      )
      Rails.logger.info("[MAIL-TEMP] Encolando correo de reset para #{user.email} (job: #{ActionMailer::Base.delivery_job})")
      PasswordsMailer.reset(user).deliver_later
    end

    head :no_content
  end

  def update
    @user.update!(
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      reset_password_token: nil,
      reset_password_sent_at: nil
    )

    head :ok
  end

  def confirm_email
    user = User.find_by!(confirmation_token: params[:token])

    user.update!(
      confirmation_token: nil,
      confirmation_sent_at: nil,
      confirmed_at: Time.current
    )

    token = JsonWebToken.encode(user_id: user.id)

    render_response({ user: user, token: token }, with: :session, status: :ok)
  end

  private

  def validate_reset_token
    @user = User.find_by!(reset_password_token: params[:token])

    raise InvalidTokenError if @user.reset_password_sent_at < 1.hour.ago
  rescue ActiveRecord::RecordNotFound
    raise InvalidTokenError
  end
end
