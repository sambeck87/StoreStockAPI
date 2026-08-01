require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'associations' do
    it { should belong_to(:store) }
    it { should have_many(:users).through(:branch_users) }
    it { should have_many(:branch_users) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    it 'validates name uniqueness scoped to the store' do
      store = create(:store)
      create(:role, store: store, name: 'cajero')

      expect(build(:role, store: store, name: 'cajero')).not_to be_valid
      expect(build(:role, store: create(:store), name: 'cajero')).to be_valid
    end
  end

  describe '#allows?' do
    let(:role) { create(:role, permissions: { 'item' => %w[index show] }) }

    it 'returns true when the action is allowed for the resource' do
      expect(role.allows?(:item, :index)).to be(true)
      expect(role.allows?(:item, 'show')).to be(true)
    end

    it 'returns false when the action is not allowed for the resource' do
      expect(role.allows?(:item, :delete)).to be(false)
    end

    it 'returns false when the resource has no permissions' do
      expect(role.allows?(:category, :index)).to be(false)
    end
  end
end
