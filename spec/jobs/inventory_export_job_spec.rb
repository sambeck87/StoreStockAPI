require 'rails_helper'

RSpec.describe InventoryExportJob, type: :job do
  let(:owner) { onboard_user }
  let(:store) { owner.store }
  let(:branch) { store.branches.find_by(is_main: true) }
  let(:category) { create(:category, store: store) }
  let!(:item) { create(:item, store: store, category: category, name: 'Azúcar', cost: 10.0) }
  let!(:branch_item) { create(:branch_item, branch: branch, item: item, current_quantity: 50, minimum_quantity: 20) }
  let(:export) { create(:inventory_export, user: owner, store: store, status: 'pending', filters: {}) }

  describe '#perform' do
    it 'generates the csv and marks the export as completed' do
      described_class.perform_now(export.id)

      export.reload
      expect(export.status).to eq('completed')
      expect(export.expires_at).to be_present
      expect(export.file).to be_attached

      csv = export.file.download.force_encoding('UTF-8')
      expect(csv).to include('Azúcar')
      expect(csv).to include('Cantidad actual')
    end

    it 'respects the filters when generating the csv' do
      export.update!(filters: { quantity_status: 'empty' })

      described_class.perform_now(export.id)

      export.reload
      expect(export.status).to eq('completed')
      expect(export.file.download.force_encoding('UTF-8')).not_to include('Azúcar')
    end

    context 'when the export is not pending anymore' do
      it 'does not regenerate it' do
        export.update!(status: 'processing')

        described_class.perform_now(export.id)

        export.reload
        expect(export.status).to eq('processing')
        expect(export.file).not_to be_attached
      end
    end

    context 'when an error occurs' do
      it 'marks the export as failed' do
        allow_any_instance_of(Items::InventoryQuery).to receive(:call).and_raise(StandardError, 'boom')

        described_class.perform_now(export.id)

        export.reload
        expect(export.status).to eq('failed')
        expect(export.error_message).to eq('boom')
      end
    end
  end
end
