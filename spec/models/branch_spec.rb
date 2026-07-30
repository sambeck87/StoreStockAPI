require 'rails_helper'

RSpec.describe Branch, type: :model do
  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:manager).class_name('User').optional }
    it { should have_many(:branch_users) }
    it { should have_many(:users).through(:branch_users) }
    it { should have_many(:branch_items) }
    it { should have_many(:items).through(:branch_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
