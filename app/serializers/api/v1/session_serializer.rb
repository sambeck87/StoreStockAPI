class Api::V1::SessionSerializer
  def initialize(user, token)
    @user = user
    @token = token
  end

  def full
    {
      email: @user.email,
      token: @token,
      expires_in: 24.hours.to_i
    }
  end
end
