class BaseSerializer
  def self.serialize(resource, view: :compact, **options)
    if resource.respond_to?(:to_ary)
      resource.map do |record|
        new(record, **options).public_send(view)
      end
    else
      new(resource, **options).public_send(view)
    end
  end
end
