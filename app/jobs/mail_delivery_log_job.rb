class MailDeliveryLogJob < ActionMailer::MailDeliveryJob
  def perform(mailer, mail_method, delivery_method, args:, kwargs: nil, params: nil)
    smtp = ActionMailer::Base.smtp_settings
    Rails.logger.info(
      "[MAIL-TEMP] Enviando correo => mailer=#{mailer}##{mail_method} " \
      "to=#{recipient(mailer, args)} smtp=#{smtp[:address]}:#{smtp[:port]} " \
      "smtp_user=#{smtp[:user_name]} mailer_from=#{ENV['MAILER_FROM']} " \
      "delivery=#{delivery_method} queue=#{queue_name}"
    )
    super
    Rails.logger.info("[MAIL-TEMP] Correo entregado OK => mailer=#{mailer}##{mail_method} to=#{recipient(mailer, args)}")
  rescue => e
    Rails.logger.error("[MAIL-TEMP] ERROR al enviar correo => mailer=#{mailer}##{mail_method} error=#{e.class}: #{e.message}")
    raise
  end

  private

  def recipient(mailer, args)
    obj = args&.first
    obj.respond_to?(:email) ? obj.email : obj.to_s
  rescue StandardError
    "?"
  end
end
