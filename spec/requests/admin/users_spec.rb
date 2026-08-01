require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:owner) { create(:user, store: nil) }
  let(:store) { create(:store, user: owner) }
  let(:main_branch) { create(:branch, store: store, is_main: true, name: 'Main') }
  let(:branch) { create(:branch, store: store, name: 'Branch 1') }

  def sign_in_as(user)
    @request.env['HTTP_AUTHORIZATION'] = "Bearer #{JsonWebToken.encode(user_id: user.id)}"
  end

  def super_admin_with(role_permissions: {})
    user = create(:user, store: store)
    role = create(:role, store: store, name: 'super_admin', permissions: role_permissions)
    create(:branch_user, user: user, branch: main_branch, role: role)
    User.includes(branch_users: [ :role, :branch ]).find(user.id)
  end

  def store_owner_super_admin(role_permissions: {})
    role = create(:role, store: store, name: 'super_admin', permissions: role_permissions)
    create(:branch_user, user: owner, branch: main_branch, role: role)
    owner.update!(store: store)
    User.includes(branch_users: [ :role, :branch ]).find(owner.id)
  end

  def regular_user_with(role_name: 'admin')
    user = create(:user, store: store)
    role = create(:role, store: store, name: role_name, permissions: {})
    create(:branch_user, user: user, branch: branch, role: role)
    User.includes(branch_users: [ :role, :branch ]).find(user.id)
  end

  describe 'DELETE #detach_store' do
    context 'when user is super admin' do
      before { sign_in_as(super_admin_with) }

      it 'removes store from user' do
        user_to_detach = create(:user, store: store)
        create(:branch_user, user: user_to_detach, branch: branch)

        delete :detach_store, params: { id: user_to_detach.id }

        expect(response).to have_http_status(:no_content)
        expect(user_to_detach.reload.store).to be_nil
      end

      it 'removes all branch_users' do
        user_to_detach = create(:user, store: store)
        create(:branch_user, user: user_to_detach, branch: branch)

        delete :detach_store, params: { id: user_to_detach.id }

        expect(user_to_detach.reload.branch_users.count).to eq(0)
      end

      it 'removes global_permission' do
        user_to_detach = create(:user, store: store)
        user_to_detach.global_permission = create(:global_permission, store: store)
        user_to_detach.save!

        delete :detach_store, params: { id: user_to_detach.id }

        expect(user_to_detach.reload.global_permission).to be_nil
      end
    end

    context 'when user is not super admin' do
      before { sign_in_as(regular_user_with) }

      it 'returns forbidden' do
        user_to_detach = create(:user, store: store)

        delete :detach_store, params: { id: user_to_detach.id }

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns not_found when the target user belongs to another store' do
        other_owner = create(:user, store: nil)
        other_store = create(:store, user: other_owner)
        other_user = create(:user, store: other_store)

        delete :detach_store, params: { id: other_user.id }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        delete :detach_store, params: { id: 1 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH #manage' do
    context 'when user is super admin' do
      before { sign_in_as(super_admin_with) }

      it 'deactivates an active user' do
        target = create(:user, store: store, active: true)

        patch :manage, params: { id: target.id, user: { active: false } }

        expect(response).to have_http_status(:ok)
        expect(target.reload.active).to be(false)
      end

      it 'activates an inactive user' do
        target = create(:user, store: store, active: false)

        patch :manage, params: { id: target.id, user: { active: true } }

        expect(response).to have_http_status(:ok)
        expect(target.reload.active).to be(true)
      end

      it 'assigns a branch and role to the user' do
        target = create(:user, store: store)
        role = create(:role, store: store, name: 'cashier')

        patch :manage, params: { id: target.id, user: { branch_id: branch.id, role_id: role.id } }

        expect(response).to have_http_status(:ok)
        branch_user = target.reload.branch_users.find_by(branch_id: branch.id)
        expect(branch_user).to be_present
        expect(branch_user.role).to eq(role)
      end

      it 'assigns a global permission to the user' do
        target = create(:user, store: store)
        permission = create(:global_permission, store: store, name: 'manager')

        patch :manage, params: { id: target.id, user: { global_permission_id: permission.id } }

        expect(response).to have_http_status(:ok)
        expect(target.reload.global_permission).to eq(permission)
      end

      it 'removes the global permission when nil is passed' do
        target = create(:user, store: store, global_permission: create(:global_permission, store: store))

        patch :manage, params: { id: target.id, user: { global_permission_id: nil } }

        expect(response).to have_http_status(:ok)
        expect(target.reload.global_permission).to be_nil
      end
    end

    context 'when user is not super admin' do
      it 'returns forbidden' do
        sign_in_as(regular_user_with)
        target = create(:user, store: store)

        patch :manage, params: { id: target.id, user: { active: false } }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        patch :manage, params: { id: 1, user: { active: false } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #revoke_access' do
    context 'when actor is the store owner super admin with permission' do
      before { sign_in_as(store_owner_super_admin(role_permissions: { 'user' => [ 'revoke_access' ] })) }

      it 'removes the branch_user and returns no content' do
        target = create(:user, store: store)
        branch_user = create(:branch_user, user: target, branch: branch, role: create(:role, store: store, name: 'cashier'))

        delete :revoke_access, params: { id: target.id, branch_id: branch.id }

        expect(response).to have_http_status(:no_content)
        expect(BranchUser.exists?(branch_user.id)).to be(false)
      end

      it 'returns not_found when the branch_user does not exist' do
        delete :revoke_access, params: { id: 999_999, branch_id: 999_999 }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when actor is super admin without revoke_access permission' do
      it 'returns forbidden' do
        sign_in_as(store_owner_super_admin(role_permissions: {}))
        target = create(:user, store: store)
        create(:branch_user, user: target, branch: branch, role: create(:role, store: store, name: 'cashier'))

        delete :revoke_access, params: { id: target.id, branch_id: branch.id }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user is not super admin' do
      it 'returns forbidden' do
        sign_in_as(regular_user_with)
        target = create(:user, store: store)
        create(:branch_user, user: target, branch: branch, role: create(:role, store: store, name: 'cashier'))

        delete :revoke_access, params: { id: target.id, branch_id: branch.id }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
