module Rendering
  extend ActiveSupport::Concern

  private

  def render_serialized(resource, status: :ok, **options)
    render(
      json: serialize(resource, **options),
      status: status
    )
  end

  def render_error(errors, status: :unprocessable_entity)
    render json: { errors: Array(errors) }, status: status
  end
end
