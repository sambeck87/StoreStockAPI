require 'rails_helper'

RSpec.describe Api::V1::RolesController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }

  before { sign_in(owner) }

  describe 'GET #index' do
    let!(:role) { create(:role, store: store, name: 'cajero') }

    it 'returns the roles of the store' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['roles'].map { |r| r['name'] }).to include('cajero')
    end
  end

  describe 'GET #show' do
    let!(:role) { create(:role, store: store, name: 'cajero') }

    it 'returns the role with its permissions' do
      get :show, params: { id: role.id }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['role']['name']).to eq('cajero')
      expect(body['role']['permissions']).to be_present
    end
  end

  describe 'POST #create' do
    it 'creates a role' do
      expect {
        post :create, params: {
          role: { name: 'gerente', permissions: { item: %w[index update] } }
        }
      }.to change(store.roles, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'returns unprocessable entity for a duplicate name' do
      create(:role, store: store, name: 'gerente')

      post :create, params: { role: { name: 'gerente', permissions: {} } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    let!(:role) { create(:role, store: store, name: 'cajero') }

    it 'updates the role' do
      patch :update, params: { id: role.id, role: { name: 'cajero senior' } }

      expect(response).to have_http_status(:ok)
      expect(role.reload.name).to eq('cajero senior')
    end
  end

  describe 'DELETE #destroy' do
    let!(:role) { create(:role, store: store, name: 'temporal') }

    it 'destroys a role without assigned users' do
      delete :destroy, params: { id: role.id }

      expect(response).to have_http_status(:no_content)
      expect(Role.exists?(role.id)).to be(false)
    end

    it 'returns unprocessable entity when the role has branch_users' do
      user = create(:user, store: store)
      branch = create(:branch, store: store)
      create(:branch_user, user: user, branch: branch, role: role)

      delete :destroy, params: { id: role.id }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
