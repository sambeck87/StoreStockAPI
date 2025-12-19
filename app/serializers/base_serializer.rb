class BaseSerializer
  def initialize(resource, view: :compact, **options)
    @resource = resource
    @view = view
    @options = options
  end

  def as_json
    public_send(@view)
  end

  def self.serialize(resource, view: :compact, **options)
    if resource.respond_to?(:to_ary)
      resource.map do |item|
        new(item, view: view, **options).as_json
      end
    else
      new(resource, view: view, **options).as_json
    end
  end
end