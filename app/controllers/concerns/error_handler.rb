module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ApiError, with: :render_api_error
    rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
    rescue_from ActionController::ParameterMissing, with: :render_missing_parameter
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::InvalidForeignKey, with: :render_invalid_foreign_key
  end

  private

  def render_api_error(error)
    render json: {
      error: {
        code: error.code,
        message: error.message,
        details: error.respond_to?(:details) ? error.details : nil
      }.compact
    }, status: error.status
  end

  def render_not_found
    render json: {
      error: {
        code: :not_found,
        message: I18n.t("errors.not_found")
      }
    }, status: :not_found
  end

  def render_invalid_foreign_key(_error)
    render json: {
      error: {
        code: :dependency_violation,
        message: I18n.t("errors.dependency_violation")
      }
    }, status: :unprocessable_entity
  end

  def render_record_invalid(error)
    render_api_error(ValidationError.new(error.record))
  end

  def render_missing_parameter(error)
    render_api_error(MissingParameterError.new(error.param))
  end
end
