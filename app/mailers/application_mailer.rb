class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "no-reply@store-stock-api.com")
  layout "mailer"
end
