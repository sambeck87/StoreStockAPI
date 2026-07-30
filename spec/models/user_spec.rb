require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:store).optional }
    it { should belong_to(:global_permission).optional }
    it { should have_many(:branch_users) }
    it { should have_many(:branches).through(:branch_users) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:full_name) }
  end
end
