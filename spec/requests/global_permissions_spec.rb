require 'rails_helper'

RSpec.describe Api::V1::GlobalPermissionsController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }

  before { sign_in(owner) }

  describe 'GET #index' do
    it 'returns the global permissions of the store' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['global_permissions'].length).to eq(1)
    end
  end

  describe 'GET #show' do
    let!(:permission) { create(:global_permission, store: store, name: 'lector') }

    it 'returns the global permission' do
      get :show, params: { id: permission.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['global_permission']['name']).to eq('lector')
    end
  end

  describe 'POST #create' do
    it 'creates a global permission' do
      expect {
        post :create, params: {
          global_permission: { name: 'editor', permissions: { item: %w[index update] } }
        }
      }.to change(store.global_permissions, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'returns unprocessable entity for a duplicate name' do
      create(:global_permission, store: store, name: 'editor')

      post :create, params: { global_permission: { name: 'editor', permissions: {} } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    let!(:permission) { create(:global_permission, store: store, name: 'lector') }

    it 'updates the global permission' do
      patch :update, params: { id: permission.id, global_permission: { name: 'colaborador' } }

      expect(response).to have_http_status(:ok)
      expect(permission.reload.name).to eq('colaborador')
    end
  end

  describe 'DELETE #destroy' do
    let!(:permission) { create(:global_permission, store: store, name: 'temporal') }

    it 'destroys the global permission' do
      delete :destroy, params: { id: permission.id }

      expect(response).to have_http_status(:no_content)
      expect(GlobalPermission.exists?(permission.id)).to be(false)
    end
  end
end
