class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3001')}/reset-password?token=#{user.reset_password_token}"

    mail(
      to: user.email,
      subject: I18n.t("passwords_mailer.reset.subject")
    )
  end
end
