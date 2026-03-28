require 'rails_helper'

RSpec.describe Api::V1::ItemsController, type: :controller do
  let(:store) { create(:store) }
  let(:user) { create(:user, store: store) }
  let(:branch) { create(:branch, store: store) }
  let(:category) { create(:category, store: store) }
  let!(:branch_user) { create(:branch_user, user: user, branch: branch) }

  before do
    user.global_permission = create(:global_permission, store: store)
    user.save!
    @request.env['HTTP_AUTHORIZATION'] = "Bearer #{JsonWebToken.encode(user_id: user.id)}"
  end

  describe 'GET #index' do
    let!(:item) { create(:item, store: store, category: category) }
    let!(:branch_item) { create(:branch_item, branch: branch, item: item) }

    it 'returns items' do
      get :index, params: { branch_id: branch.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns created status' do
        post :create, params: {
          item: {
            name: 'New Item',
            measure: 'pieza',
            cost: 10.50,
            active: true,
            category_id: category.id,
            current_quantity: 100,
            minimum_quantity: 10
          },
          branch_id: branch.id
        }

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity' do
        post :create, params: {
          item: { name: '' },
          category_id: category.id,
          branch_id: branch.id
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
