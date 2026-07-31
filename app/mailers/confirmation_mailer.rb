class ConfirmationMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    @confirmation_url = "#{Rails.application.config.x.frontend_url}/confirm-email?token=#{user.confirmation_token}"

    mail(
      to: user.email,
      subject: I18n.t("confirmation_mailer.confirmation.subject")
    )
  end
end
