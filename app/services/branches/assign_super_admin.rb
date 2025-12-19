module Branches
  class AssignSuperAdmin
    def initialize(branch:, user:)
      @branch = branch
      @user = user
    end

    def call
      role = find_or_create_role!

      BranchUser.create!(
        branch: @branch,
        user: @user,
        role: role
      )
    end

    private

    def find_or_create_role!
      Role.find_or_create_by!(
        store: @branch.store,
        name: "super_admin"
      ) do |role|
        role.permissions = Role::ALL_PERMISSIONS
      end
    end
  end
end
