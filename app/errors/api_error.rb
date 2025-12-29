class ApiError < StandardError
  attr_reader :status, :code

  def initialize(message = nil, status: 400, code: nil)
    super(message)
    @status = status
    @code = code
  end
end

class AuthenticationError < ApiError
  def initialize(message = "Invalid credentials")
    super(message, status: 401, code: :authentication_failed)
  end
end

class AuthorizationError < ApiError
  def initialize(message = "Not authorized")
    super(message, status: 403, code: :not_authorized)
  end
end

class InvalidTokenError < ApiError
  def initialize(message = "Invalid or expired token")
    super(message, status: 401, code: :invalid_token)
  end
end

class BusinessRuleError < ApiError
  def initialize(message)
    super(message, status: 422, code: :business_rule_violation)
  end
end

class ValidationError < ApiError
  attr_reader :details

  def initialize(record)
    super(
      I18n.t("errors.validation_failed"),
      status: 422,
      code: :validation_failed
    )

    @details = record.errors.to_hash(true)
  end
end

class UnauthorizedError < ApiError
  def initialize
    super(
      I18n.t("errors.unauthorized"),
      status: 401
    )
  end
end

class NotFoundError < ApiError
  def initialize
    super(
      I18n.t("errors.not_found"),
      status: 404,
      code: :not_found
    )
  end
end
