class Api::V1::SessionResponse
  def initialize(payload)
    @user  = payload[:user]
    @token = payload[:token]
  end

  def as_json(*)
    {
      user: {
        id: @user.id,
        email: @user.email,
        store_id: @user.store_id
      },
      token: @token,
      expires_in: 24.hours.to_i
    }
  end
end
