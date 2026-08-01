require 'rails_helper'

RSpec.describe Api::V1::Inventory::ExportsController, type: :controller do
  let(:owner) { onboard_user }
  let(:store) { owner.store }
  let(:branch) { store.branches.find_by(is_main: true) }
  let(:category) { create(:category, store: store) }

  before { sign_in(owner) }

  describe 'POST #create' do
    context 'when there are items in the inventory' do
      let!(:item) { create(:item, store: store, category: category, name: 'Refresco') }
      let!(:branch_item) { create(:branch_item, branch: branch, item: item, current_quantity: 10, minimum_quantity: 5) }

      it 'creates an export and enqueues the export job' do
        expect {
          post :create
        }.to change(InventoryExport, :count).by(1)
         .and have_enqueued_job(InventoryExportJob)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body['status']).to eq('pending')
        expect(body['download_url']).to be_nil
      end
    end

    context 'when the inventory is empty' do
      it 'returns unprocessable entity' do
        post :create

        expect(response).to have_http_status(:unprocessable_entity)
        expect(InventoryExport.count).to eq(0)
      end
    end
  end

  describe 'GET #show' do
    let!(:export) { create(:inventory_export, user: owner, store: store, status: 'processing', filters: {}) }

    it 'returns the export status' do
      get :show, params: { id: export.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(export.id)
    end
  end

  describe 'GET #download' do
    context 'when the export is completed' do
      let!(:export) do
        record = create(:inventory_export, user: owner, store: store, status: 'completed', expires_at: 1.hour.from_now)
        record.file.attach(io: StringIO.new("ID,Nombre\n1,Refresco\n"), filename: 'inventario_exportacion.csv', content_type: 'text/csv')
        record
      end

      it 'sends the csv file' do
        get :download, params: { id: export.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Refresco')
      end
    end

    context 'when the export is not ready' do
      let!(:export) { create(:inventory_export, user: owner, store: store, status: 'pending') }

      it 'returns not_found' do
        get :download, params: { id: export.id }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
