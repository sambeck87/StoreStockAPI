class Stores::OnboardStore
  def initialize(user:, store_params:)
    @user = user
    @store_params = store_params
  end

  def call
    ActiveRecord::Base.transaction do
      store = Stores::CreateStore.new(
        user: @user,
        params: @store_params
      ).call

      @user.update!(store: store, active: true)

      GlobalPermissions::AssignGlobalPermissions.new(user: @user).call

      main_branch = Branches::CreateMainBranch.new(
        store: store,
        manager: @user
      ).call

      Branches::AssignSuperAdmin.new(
        branch: main_branch,
        user: @user
      ).call

      store
    end
  end
end
