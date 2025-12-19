class Api::V1::UserSerializer < BaseSerializer
  def full
    {
      id: @resource.id,
      email: @resource.email,
      full_name: @resource.full_name,
      active: @resource.active
    }
  end

  def compact
    {
      full_name: @resource.full_name,
      active: @resource.active
    }
  end
end