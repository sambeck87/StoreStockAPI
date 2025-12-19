class JsonWebToken
  SECRET_KEY = Rails.application.credentials.dig(:jwt, :secret)
  ALGORITHM = "HS256"
  TTL = 24.hours

  def self.encode(payload)
    payload[:exp] = TTL.from_now.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
    decoded.first.with_indifferent_access
  rescue JWT::ExpiredSignature, JWT::DecodeError
    nil
  end
end
