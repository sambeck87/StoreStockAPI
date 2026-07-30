require 'rails_helper'

RSpec.describe BranchItem, type: :model do
  describe 'associations' do
    it { should belong_to(:branch) }
    it { should belong_to(:item) }
    it { should belong_to(:updated_by).class_name('User').optional }
  end
end
