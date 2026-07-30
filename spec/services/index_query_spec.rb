require 'rails_helper'

RSpec.describe Items::IndexQuery, type: :service do
  let(:store) { create(:store) }
  let(:user) { create(:user, store: store) }
  let(:branch1) { create(:branch, store: store, is_main: true) }
  let(:branch2) { create(:branch, store: store, is_main: false) }
  let(:category1) { create(:category, store: store) }
  let(:category2) { create(:category, store: store) }
  let!(:item1) { create(:item, store: store, category: category1, name: 'Item 1') }
  let!(:item2) { create(:item, store: store, category: category2, name: 'Item 2') }
  let!(:branch_item1) { create(:branch_item, branch: branch1, item: item1) }
  let!(:branch_item2) { create(:branch_item, branch: branch2, item: item2) }

  describe '#call' do
    context 'without filters' do
      it 'returns all items from the store' do
        result = described_class.new(
          current_user: user,
          current_branch: nil,
          params: {}
        ).call

        expect(result.count).to eq(2)
      end
    end

    context 'filtering by category_id' do
      it 'returns items from that category only' do
        result = described_class.new(
          current_user: user,
          current_branch: nil,
          params: { category_id: category1.id }
        ).call

        expect(result.count).to eq(1)
        expect(result.first).to eq(item1)
      end
    end

    context 'filtering by branch_id' do
      it 'returns items from that branch only' do
        result = described_class.new(
          current_user: user,
          current_branch: nil,
          params: { branch_id: branch1.id }
        ).call

        expect(result.count).to eq(1)
        expect(result.first).to eq(item1)
      end
    end

    context 'filtering by active' do
      let!(:inactive_item) { create(:item, store: store, category: category1, name: 'Inactive', active: false) }

      it 'returns only active items when active=true' do
        result = described_class.new(
          current_user: user,
          current_branch: nil,
          params: { active: true }
        ).call

        expect(result.count).to eq(2)
        expect(result).not_to include(inactive_item)
      end
    end
  end
end
