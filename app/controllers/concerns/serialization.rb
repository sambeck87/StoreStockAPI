# app/controllers/concerns/serialization.rb
module Serialization
  extend ActiveSupport::Concern

  private

  def serialize(resource, with: nil, view: :compact, key: nil, **options)
    serializer_class = resolve_serializer(resource, with)
    payload = serializer_class.serialize(resource, view: view, **options)

    key ||= infer_key(resource, serializer_class)

    { key => payload }
  end

  def resolve_serializer(resource, with)
    return with if with.is_a?(Class)

    name =
      if with
        with.to_s.classify
      else
        resource_class_name(resource)
      end

    "#{serializer_namespace}::#{name}Serializer".constantize
  end

  def infer_key(resource, serializer_class)
    base = serializer_class.name.demodulize
                               .sub("Serializer", "")
                               .underscore

    resource.respond_to?(:to_ary) ? base.pluralize.to_sym : base.to_sym
  end

  def resource_class_name(resource)
    if resource.respond_to?(:to_ary)
      resource.first&.class&.name || "Unknown"
    else
      resource.class.name
    end
  end

  def serializer_namespace
    self.class.module_parent.name
  end
end
