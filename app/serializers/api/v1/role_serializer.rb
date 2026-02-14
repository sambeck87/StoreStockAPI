class Api::V1::RoleSerializer < BaseSerializer
  def initialize(role)
    @role = role
  end

  def compact
    {
      id: @role.id,
      name: @role.name
    }
  end

  def full
    {
      id: @role.id,
      name: @role.name,
      permissions: @role.permissions
    }
  end
end