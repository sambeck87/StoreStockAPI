module Serialization
  extend ActiveSupport::Concern

  private

  def serialize(resource, with:, view: :compact, **options)
    serializer_class =
      if with.is_a?(Class)
        with
      else
        default_serializer_for(with)
      end

    serializer_class.serialize(resource, view: view, **options)
  end

  def default_serializer_for(name)
    namespace = self.class.module_parent
    "#{namespace}::#{name.to_s.classify}Serializer".constantize
  end
end
