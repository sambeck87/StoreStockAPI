class Api::V1::UserSerializer < BaseSerializer
  def initialize(user)
    @user = user
  end

  def compact
    {
      id: @user.id,
      full_name: @user.full_name,
      email: @user.email,
      active: @user.active
    }
  end

  def full
    {
      id: @user.id,
      email: @user.email,
      full_name: @user.full_name,
      store_id: @user.store_id,
      branch_ids: @user.branches.pluck(:id),
      active: @user.active
    }
  end
end