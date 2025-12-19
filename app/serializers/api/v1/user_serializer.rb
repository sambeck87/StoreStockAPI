class Api::V1::UserSerializer < BaseSerializer
  def initialize(user)
    @user = user
  end

  def compact
    {
      full_name: @user.full_name,
      active: @user.active
    }
  end

  def full
    {
      id: @user.id,
      email: @user.email,
      full_name: @user.full_name,
      active: @user.active
    }
  end
end