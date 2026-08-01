require 'rails_helper'

RSpec.describe InventoryExport, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:store) }
    it { should have_one_attached(:file) }
  end

  describe 'status predicates' do
    it 'is pending when status is pending' do
      expect(build(:inventory_export, status: 'pending')).to be_pending
    end

    it 'is processing when status is processing' do
      expect(build(:inventory_export, status: 'processing')).to be_processing
    end

    it 'is completed when status is completed' do
      expect(build(:inventory_export, status: 'completed')).to be_completed
    end

    it 'is failed when status is failed' do
      expect(build(:inventory_export, status: 'failed')).to be_failed
    end
  end

  describe '#expired?' do
    it 'is expired when expires_at is in the past' do
      expect(build(:inventory_export, expires_at: 1.hour.ago)).to be_expired
    end

    it 'is not expired when expires_at is in the future' do
      expect(build(:inventory_export, expires_at: 1.hour.from_now)).not_to be_expired
    end

    it 'is not expired when expires_at is nil' do
      expect(build(:inventory_export, expires_at: nil)).not_to be_expired
    end
  end

  describe '#downloadable?' do
    it 'is downloadable when completed and not expired' do
      export = build(:inventory_export, status: 'completed', expires_at: 1.hour.from_now)
      expect(export).to be_downloadable
    end

    it 'is not downloadable when completed but expired' do
      export = build(:inventory_export, status: 'completed', expires_at: 1.hour.ago)
      expect(export).not_to be_downloadable
    end

    it 'is not downloadable when not completed' do
      export = build(:inventory_export, status: 'processing', expires_at: 1.hour.from_now)
      expect(export).not_to be_downloadable
    end
  end
end
