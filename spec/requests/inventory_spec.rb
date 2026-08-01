require 'rails_helper'

RSpec.describe Api::V1::InventoryController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }
  let(:branch) { store.branches.find_by(is_main: true) }
  let(:category) { create(:category, store: store) }

  before { sign_in(owner) }

  let!(:complete_item) { create(:item, store: store, category: category, name: 'Completo') }
  let!(:complete_bi) { create(:branch_item, branch: branch, item: complete_item, current_quantity: 50, minimum_quantity: 10) }
  let!(:low_item) { create(:item, store: store, category: category, name: 'Bajo') }
  let!(:low_bi) { create(:branch_item, branch: branch, item: low_item, current_quantity: 3, minimum_quantity: 10) }
  let!(:empty_item) { create(:item, store: store, category: category, name: 'Vacio') }
  let!(:empty_bi) { create(:branch_item, branch: branch, item: empty_item, current_quantity: 0, minimum_quantity: 10) }

  describe 'GET #index' do
    it 'returns all inventory rows' do
      get :index

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['items'].length).to eq(3)
      expect(body['meta']['total']).to eq(3)
    end

    it 'reports quantity_status for each item' do
      get :index

      items = JSON.parse(response.body)['items'].index_by { |i| i['name'] }
      expect(items['Completo']['quantity_status']).to eq('complete')
      expect(items['Bajo']['quantity_status']).to eq('low')
      expect(items['Vacio']['quantity_status']).to eq('empty')
    end

    it 'filters by quantity_status complete' do
      get :index, params: { quantity_status: 'complete' }

      items = JSON.parse(response.body)['items']
      expect(items.length).to eq(1)
      expect(items.first['name']).to eq('Completo')
    end

    it 'filters by quantity_status low' do
      get :index, params: { quantity_status: 'low' }

      items = JSON.parse(response.body)['items']
      expect(items.length).to eq(1)
      expect(items.first['name']).to eq('Bajo')
    end

    it 'filters by quantity_status empty' do
      get :index, params: { quantity_status: 'empty' }

      items = JSON.parse(response.body)['items']
      expect(items.length).to eq(1)
      expect(items.first['name']).to eq('Vacio')
    end
  end
end
