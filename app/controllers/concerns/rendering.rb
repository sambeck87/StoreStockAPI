module Rendering
  extend ActiveSupport::Concern

  private

  def render_resource(key, data, status: :ok, meta: nil)
    payload = { key => data }
    payload[:meta] = meta if meta

    render json: payload, status: status
  end

  def render_error(errors, status: :unprocessable_entity)
    render json: { errors: Array(errors) }, status: status
  end
end
