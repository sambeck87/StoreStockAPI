require 'rails_helper'

RSpec.describe Api::V1::StoresController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }

  before { sign_in(owner) }

  describe 'GET #index' do
    it 'returns the accessible stores' do
      get :index

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['stores'].map { |s| s['id'] }).to include(store.id)
    end
  end

  describe 'GET #show' do
    it 'returns the store' do
      get :show, params: { id: store.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['store']['id']).to eq(store.id)
    end

    it 'returns forbidden for a store the user does not own' do
      other_store = create(:store)

      get :show, params: { id: other_store.id }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST #create' do
    it 'onboards a new store for the user' do
      new_user = create(:user, store: nil, active: true)
      sign_in(new_user)

      expect {
        post :create, params: { store: { name: 'Mi Nueva Tienda' } }
      }.to change(Store, :count).by(1)

      expect(response).to have_http_status(:created)

      new_user.reload
      expect(new_user.store.name).to eq('Mi Nueva Tienda')
      expect(new_user).to be_super_admin
      expect(new_user.global_permission).to be_present
      expect(new_user.store.branches.find_by(is_main: true)).to be_present
    end
  end

  describe 'PATCH #update' do
    it 'updates the store name' do
      patch :update, params: { id: store.id, store: { name: 'Nombre Actualizado' } }

      expect(response).to have_http_status(:ok)
      expect(store.reload.name).to eq('Nombre Actualizado')
    end

    it 'returns forbidden for a store the user does not own' do
      other_store = create(:store)

      patch :update, params: { id: other_store.id, store: { name: 'Hack' } }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the store with its dependencies' do
      create(:category, store: store)
      create(:role, store: store)

      delete :destroy, params: { id: store.id }

      expect(response).to have_http_status(:no_content)
      expect(Store.exists?(store.id)).to be(false)
      expect(Category.where(store_id: store.id)).to be_empty
    end
  end
end
