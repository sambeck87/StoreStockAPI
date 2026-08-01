require 'rails_helper'

RSpec.describe Api::V1::ItemsController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }
  let(:branch) { store.branches.find_by(is_main: true) }
  let(:category) { create(:category, store: store) }

  before { sign_in(owner) }

  describe 'GET #index' do
    let!(:item) { create(:item, store: store, category: category, name: 'Arroz') }
    let!(:branch_item) { create(:branch_item, branch: branch, item: item) }

    it 'returns the items of the branch with pagination meta' do
      get :index, params: { branch_id: branch.id }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['items'].length).to eq(1)
      expect(body['meta']['total']).to eq(1)
    end

    it 'filters by active items' do
      inactive = create(:item, store: store, category: category, active: false)
      create(:branch_item, branch: branch, item: inactive)

      get :index, params: { branch_id: branch.id, active: true }

      items = JSON.parse(response.body)['items']
      expect(items.all? { |i| i['active'] == true }).to be(true)
    end
  end

  describe 'GET #show' do
    let!(:item) { create(:item, store: store, category: category) }
    let!(:branch_item) { create(:branch_item, branch: branch, item: item, current_quantity: 5, minimum_quantity: 10) }

    it 'returns the item with its quantity status' do
      get :show, params: { id: item.id, branch_id: branch.id }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['item']['id']).to eq(item.id)
      expect(body['item']['quantity_status']).to eq('low')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates the item and its branch stock' do
        expect {
          post :create, params: {
            item: {
              name: 'Frijol',
              measure: 'kilo',
              cost: 20.5,
              current_quantity: 100,
              minimum_quantity: 25
            },
            category_id: category.id,
            branch_id: branch.id
          }
        }.to change(Item, :count).by(1).and change(BranchItem, :count).by(1)

        expect(response).to have_http_status(:created)
        item = Item.last
        expect(item.name).to eq('Frijol')
        expect(item.created_by).to eq(owner)
        branch_item = item.branch_items.find_by(branch_id: branch.id)
        expect(branch_item.current_quantity).to eq(100)
        expect(branch_item.minimum_quantity).to eq(25)
      end

      it 'normalizes the item name' do
        post :create, params: {
          item: { name: '  frijol negro  ', measure: 'kilo' },
          category_id: category.id,
          branch_id: branch.id
        }

        expect(response).to have_http_status(:created)
        expect(Item.last.name).to eq('Frijol Negro')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity' do
        post :create, params: {
          item: { name: '', measure: '' },
          category_id: category.id,
          branch_id: branch.id
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:item) { create(:item, store: store, category: category) }

    it 'updates the item attributes' do
      patch :update, params: { id: item.id, branch_id: branch.id, item: { name: 'Arroz Integral', cost: 12.0 } }

      expect(response).to have_http_status(:ok)
      expect(item.reload.name).to eq('Arroz Integral')
      expect(item.reload.cost.to_f).to eq(12.0)
      expect(item.reload.updated_by).to eq(owner)
    end

    it 'updates the branch stock when branch_id is passed' do
      patch :update, params: {
        id: item.id,
        branch_id: branch.id,
        item: { current_quantity: 55, minimum_quantity: 15, active: true }
      }

      expect(response).to have_http_status(:ok)
      branch_item = item.reload.branch_items.find_by(branch_id: branch.id)
      expect(branch_item.current_quantity).to eq(55)
      expect(branch_item.minimum_quantity).to eq(15)
    end
  end

  describe 'DELETE #destroy' do
    let!(:item) { create(:item, store: store, category: category) }

    it 'destroys the item' do
      delete :destroy, params: { id: item.id, branch_id: branch.id }

      expect(response).to have_http_status(:no_content)
      expect(Item.exists?(item.id)).to be(false)
    end
  end
end
