class Api::V1::GlobalPermissionSerializer < BaseSerializer
  def initialize(global_permission)
    @global_permission = global_permission
  end

  def compact
    {
      id: @global_permission.id,
      name: @global_permission.name
    }
  end

  def full
    {
      id: @global_permission.id,
      name: @global_permission.name,
      permissions: @global_permission.permissions
    }
  end
end