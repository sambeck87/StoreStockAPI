require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }
  let!(:category) { create(:category, store: store, name: 'Limpieza') }

  before { sign_in(owner) }

  describe 'GET #index' do
    it 'returns the categories with pagination meta' do
      get :index

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['categories'].length).to eq(1)
      expect(body['meta']).to include('total', 'page', 'per_page', 'total_pages')
    end

    it 'filters by name' do
      create(:category, store: store, name: 'Repuestos')

      get :index, params: { name: 'Repuestos' }

      names = JSON.parse(response.body)['categories'].map { |c| c['name'] }
      expect(names).to eq([ 'Repuestos' ])
    end
  end

  describe 'GET #show' do
    it 'returns the category' do
      get :show, params: { id: category.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['category']['id']).to eq(category.id)
    end
  end

  describe 'POST #create' do
    it 'creates an active category with created_by set' do
      expect {
        post :create, params: { category: { name: 'Bebidas' } }
      }.to change(store.categories, :count).by(1)

      expect(response).to have_http_status(:created)
      new_category = store.categories.last
      expect(new_category.created_by).to eq(owner)
      expect(new_category.active).to be(true)
    end

    it 'returns unprocessable entity for a duplicate name' do
      create(:category, store: store, name: 'Bebidas')

      post :create, params: { category: { name: 'Bebidas' } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'updates the category and sets updated_by' do
      patch :update, params: { id: category.id, category: { name: 'Higiene' } }

      expect(response).to have_http_status(:ok)
      expect(category.reload.name).to eq('Higiene')
      expect(category.reload.updated_by).to eq(owner)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys a category without items' do
      delete :destroy, params: { id: category.id }

      expect(response).to have_http_status(:no_content)
      expect(Category.exists?(category.id)).to be(false)
    end

    it 'returns unprocessable entity when the category has items' do
      create(:item, store: store, category: category)

      delete :destroy, params: { id: category.id }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
