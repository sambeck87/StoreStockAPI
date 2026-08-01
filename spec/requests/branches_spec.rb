require 'rails_helper'

RSpec.describe Api::V1::BranchesController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }
  let!(:branch) { create(:branch, store: store, name: 'Sucursal Norte') }

  before { sign_in(owner) }

  describe 'GET #index' do
    it 'returns the branches of the store' do
      get :index

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['branches'].length).to eq(2)
    end
  end

  describe 'GET #show' do
    it 'returns a branch the user belongs to' do
      main_branch = store.branches.find_by(is_main: true)

      get :show, params: { id: main_branch.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['branch']['id']).to eq(main_branch.id)
    end

    it 'returns forbidden for a branch the user does not belong to' do
      get :show, params: { id: branch.id }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a branch and assigns the manager' do
        expect {
          post :create, params: { branch: { name: 'Sucursal Sur', manager_id: owner.id } }
        }.to change(store.branches, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(store.branches.last.manager).to eq(owner)
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity' do
        post :create, params: { branch: { name: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the user is not a super admin' do
      it 'returns forbidden' do
        member = create(:user, store: store)
        member.global_permission = full_access_permission(store)
        member.save!
        sign_in(member)

        post :create, params: { branch: { name: 'Sucursal X' } }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH #update' do
    it 'updates the branch name' do
      patch :update, params: { id: branch.id, branch: { name: 'Sucursal Renombrada' } }

      expect(response).to have_http_status(:ok)
      expect(branch.reload.name).to eq('Sucursal Renombrada')
    end

    it 'does not allow changing the manager of the main branch' do
      main_branch = store.branches.find_by(is_main: true)

      patch :update, params: { id: main_branch.id, branch: { manager_id: owner.id } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys a non-main branch' do
      delete :destroy, params: { id: branch.id }

      expect(response).to have_http_status(:no_content)
      expect(Branch.exists?(branch.id)).to be(false)
    end

    it 'does not allow destroying the main branch' do
      main_branch = store.branches.find_by(is_main: true)

      delete :destroy, params: { id: main_branch.id }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
