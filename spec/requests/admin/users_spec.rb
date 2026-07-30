require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:store) { create(:store) }
  let(:main_branch) { create(:branch, store: store, is_main: true, name: 'Main') }
  let(:branch) { create(:branch, store: store, name: 'Branch 1') }

  let(:super_admin_role) { create(:role, store: store, name: "super_admin", permissions: {}) }

  describe 'DELETE #detach_store' do
    context 'when user is super_admin' do
      let(:super_admin) do
        user = create(:user, store: store)
        create(:branch_user, user: user, branch: main_branch, role: super_admin_role)
        User.includes(branch_users: [ :role, :branch ]).find(user.id)
      end

      before do
        @request.env['HTTP_AUTHORIZATION'] = "Bearer #{JsonWebToken.encode(user_id: super_admin.id)}"
      end

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
      let(:regular_role) { create(:role, store: store, name: "admin", permissions: {}) }
      let(:regular_user) do
        user = create(:user, store: store)
        create(:branch_user, user: user, branch: branch, role: regular_role)
        User.includes(branch_users: [ :role, :branch ]).find(user.id)
      end

      before do
        @request.env['HTTP_AUTHORIZATION'] = "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}"
      end

      it 'returns unauthorized' do
        user_to_detach = create(:user, store: store)

        delete :detach_store, params: { id: user_to_detach.id }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
