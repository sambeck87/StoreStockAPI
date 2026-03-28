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

class DependencyViolationError < ApiError
  attr_reader :details

  def initialize(message, details: {})
    super(message, status: 422, code: :dependency_violation)
    @details = details
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

class MissingParameterError < ApiError
  def initialize(param)
    super(
      I18n.t("errors.missing_parameter"),
      status: 400,
      code: :missing_parameter
    )

    @details = { param: param }
  end

  attr_reader :details
end

class InactiveUserError < ApiError
  def initialize
    super(
      I18n.t("errors.user_inactive"),
      status: 403,
      code: :user_inactive
    )
  end
end

class UnconfirmedEmailError < ApiError
  def initialize
    super(
      I18n.t("errors.unconfirmed_email"),
      status: 401,
      code: :unconfirmed_email
    )
  end
end
