require 'rails_helper'

RSpec.describe CleanupInventoryExportsJob, type: :job do
  let(:owner) { onboard_user }
  let(:store) { owner.store }

  it 'destroys expired exports and purges their files' do
    expired = create(:inventory_export, user: owner, store: store, status: 'completed', expires_at: 5.minutes.ago)
    expired.file.attach(io: StringIO.new("ID\n1\n"), filename: 'vieja.csv', content_type: 'text/csv')

    described_class.perform_now

    expect(InventoryExport.exists?(expired.id)).to be(false)
  end

  it 'keeps exports that are not expired' do
    current = create(:inventory_export, user: owner, store: store, status: 'completed', expires_at: 30.minutes.from_now)

    described_class.perform_now

    expect(InventoryExport.exists?(current.id)).to be(true)
  end
end
