class ConfirmationMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    @confirmation_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:5173')}/confirm-email?token=#{user.confirmation_token}"

    mail(
      to: user.email,
      subject: I18n.t("confirmation_mailer.confirmation.subject")
    )
  end
end
