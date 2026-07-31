class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @reset_url = "#{Rails.application.config.x.frontend_url}/reset-password?token=#{user.reset_password_token}"

    mail(
      to: user.email,
      subject: I18n.t("passwords_mailer.reset.subject")
    )
  end
end
