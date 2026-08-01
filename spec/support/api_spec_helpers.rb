module ApiSpecHelpers
  def sign_in(user)
    @request.env['HTTP_AUTHORIZATION'] = "Bearer #{JsonWebToken.encode(user_id: user.id)}"
  end

  def full_access_permission(store)
    GlobalPermission.find_or_create_by!(store: store, name: 'Full Access') do |gp|
      gp.permissions = GlobalPermission::ALL_PERMISSIONS
    end
  end

  def onboard_user(store_name: 'Tienda de Prueba')
    user = create(:user, store: nil, active: true)
    Stores::OnboardStore.new(user: user, store_params: { name: store_name }).call
    user.reload
  end
end
