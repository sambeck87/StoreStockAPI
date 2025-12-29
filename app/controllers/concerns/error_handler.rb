module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ::ApiError, with: :render_api_error
    rescue_from ActiveRecord::RecordNotFound do
      raise NotFoundError
    end
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
end
