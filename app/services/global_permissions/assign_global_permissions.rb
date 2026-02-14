module GlobalPermissions
  class AssignGlobalPermissions
    def initialize(user:)
      @user = user
    end

    def call
      global_permission = GlobalPermission.create!(
        name: "Full Access",
        permissions: GlobalPermission::ALL_PERMISSIONS,
        store: @user.store,
        )

      @user.update!(global_permission: global_permission)
    end
  end
end