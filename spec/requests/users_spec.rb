require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }

  before { sign_in(owner) }

  describe 'GET #index' do
    it 'returns the users of the store' do
      create(:user, store: store, full_name: 'Miembro Uno')

      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['users'].map { |u| u['full_name'] }).to include('Miembro Uno')
    end

    it 'filters by active users' do
      create(:user, store: store, active: false)

      get :index, params: { active: 'true' }

      users = JSON.parse(response.body)['users']
      expect(users.all? { |u| u['active'] == true }).to be(true)
    end
  end

  describe 'GET #show' do
    it 'returns the own profile' do
      get :show, params: { id: owner.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['user']['id']).to eq(owner.id)
    end

    it 'returns another user of the store' do
      member = create(:user, store: store)

      get :show, params: { id: member.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['user']['id']).to eq(member.id)
    end
  end

  describe 'PATCH #update' do
    it 'updates the own full name' do
      patch :update, params: { id: owner.id, user: { full_name: 'Nombre Actualizado' } }

      expect(response).to have_http_status(:ok)
      expect(owner.reload.full_name).to eq('Nombre Actualizado')
    end

    it 'assigns a store to a user' do
      member = create(:user, store: nil)
      other_store = create(:store)

      patch :update, params: { id: member.id, user: { store_id: other_store.id } }

      expect(response).to have_http_status(:ok)
      expect(member.reload.store).to eq(other_store)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys a user that manages no branches' do
      member = create(:user, store: store)

      delete :destroy, params: { id: member.id }

      expect(response).to have_http_status(:no_content)
      expect(User.exists?(member.id)).to be(false)
    end

    it 'returns unprocessable entity for a user who manages a branch' do
      manager = create(:user, store: store)
      create(:branch, store: store, manager: manager)

      delete :destroy, params: { id: manager.id }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
