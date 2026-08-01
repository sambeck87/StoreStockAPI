require 'rails_helper'

RSpec.describe GlobalPermission, type: :model do
  describe 'associations' do
    it { should belong_to(:store) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:permissions) }

    it 'validates name uniqueness scoped to the store' do
      store = create(:store)
      create(:global_permission, store: store, name: 'lector')

      expect(build(:global_permission, store: store, name: 'lector')).not_to be_valid
      expect(build(:global_permission, store: create(:store), name: 'lector')).to be_valid
    end
  end

  describe '#allows?' do
    let(:permission) { create(:global_permission, permissions: { 'item' => %w[index show] }) }

    it 'returns true when the action is allowed for the resource' do
      expect(permission.allows?(:item, :index)).to be(true)
    end

    it 'returns false when the action is missing for the resource' do
      expect(permission.allows?(:item, :delete)).to be(false)
    end

    it 'returns false when the resource is unknown' do
      expect(permission.allows?(:product, :index)).to be(false)
    end

    it 'returns false when the action is not a valid permission' do
      expect(permission.allows?(:item, :destroy_all)).to be(false)
    end

    it 'returns false when the resource has no permissions defined' do
      expect(permission.allows?(:category, :index)).to be(false)
    end

    it 'knows all valid resources and actions' do
      expect(GlobalPermission::ALL_PERMISSIONS.keys).to include(:user, :store, :branch, :category, :item, :role, :global_permission)
      expect(GlobalPermission::ALL_PERMISSIONS[:user]).to include(:manage, :revoke_access, :detach_store)
    end
  end
end
