require 'rails_helper'
require_relative '../../app/errors/api_error'

RSpec.describe Items::CreateItem, type: :service do
  let(:store) { create(:store) }
  let(:user) { create(:user, store: store) }
  let(:branch) { create(:branch, store: store) }
  let(:category) { create(:category, store: store) }
  let!(:branch_user) { create(:branch_user, user: user, branch: branch) }

  let(:params) do
    {
      name: 'Test Item',
      measure: 'pieza',
      cost: 10.50,
      active: true,
      category_id: category.id,
      current_quantity: 100,
      minimum_quantity: 10
    }
  end

  describe '#call' do
    context 'when user does not have global permission' do
      it 'creates a new item with the user branch' do
        result = described_class.new(user: user, params: params, current_branch: branch).call
        result.save!

        expect(result.item).to be_persisted
        expect(result.item.name).to eq('Test Item')
        expect(result.item.store).to eq(store)
        expect(result.branch_item.branch).to eq(branch)
        expect(result.branch_item.current_quantity).to eq(100)
        expect(result.branch_item.minimum_quantity).to eq(10)
      end
    end

    context 'when item already exists in the store' do
      let!(:existing_item) { create(:item, store: store, category: category, name: 'Test Item') }

      it 'reuses the existing item' do
        result = described_class.new(user: user, params: params, current_branch: branch).call

        expect(result.item).to eq(existing_item)
        expect(result.item).to be_persisted
      end
    end

    context 'when category does not exist' do
      let(:invalid_params) { params.merge(category_id: 99999) }

      it 'raises NotFoundError' do
        expect {
          described_class.new(user: user, params: invalid_params, current_branch: branch).call
        }.to raise_error(NotFoundError)
      end
    end

    context 'when branch item already exists' do
      let!(:existing_item) { create(:item, store: store, category: category, name: 'Test Item') }
      let!(:existing_branch_item) { create(:branch_item, branch: branch, item: existing_item) }

      it 'raises DependencyViolationError' do
        expect {
          described_class.new(user: user, params: params, current_branch: branch).call
        }.to raise_error(DependencyViolationError)
      end
    end

    context 'when name has extra spaces' do
      let(:params_with_spaces) { params.merge(name: '  test item  ') }

      it 'normalizes name to titleize' do
        result = described_class.new(user: user, params: params_with_spaces, current_branch: branch).call

        expect(result.item.name).to eq('Test Item')
      end
    end
  end
end
