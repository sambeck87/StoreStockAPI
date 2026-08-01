require 'rails_helper'

RSpec.describe Store, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      expect(Store.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
    it { should have_many(:branches).dependent(:destroy) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:roles).dependent(:destroy) }
    it { should have_many(:global_permissions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:user) }

    it 'does not allow two stores owned by the same user' do
      user = create(:user, store: nil)
      create(:store, user: user)

      expect(build(:store, user: user)).not_to be_valid
    end

    it 'allows different users to own stores' do
      expect(create(:store)).to be_valid
    end
  end
end
