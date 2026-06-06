ENV["SSL_CERT_FILE"] ||= "/etc/ssl/certs/ca-certificates.crt"
Resend.api_key = ENV.fetch("RESEND_API_KEY")