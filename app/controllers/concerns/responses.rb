module Responses
  extend ActiveSupport::Concern

  private

  def render_response(payload, with:, status: :ok, **options)
    response_class = resolve_response(with)
    body = response_class.new(payload, **options).as_json

    render json: body, status: status
  end

  def resolve_response(with)
    return with if with.is_a?(Class)

    name = with.to_s.classify
    "#{response_namespace}::#{name}Response".constantize
  end

  def response_namespace
    self.class.module_parent.name
  end
end
