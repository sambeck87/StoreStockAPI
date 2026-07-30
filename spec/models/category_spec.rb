require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:created_by).class_name('User').optional }
    it { should belong_to(:updated_by).class_name('User').optional }
    it { should have_many(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
