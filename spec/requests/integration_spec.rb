require 'rails_helper'

RSpec.describe 'Store Stock API integration flow', type: :request do
  describe 'complete onboarding to export flow' do
    it 'signs up, confirms, logs in, creates inventory and exports a csv' do
      post '/api/v1/registration', params: {
        user: { email: 'juan@ejemplo.com', password: 'Password1', password_confirmation: 'Password1', full_name: 'Juan Pérez' }
      }
      expect(response).to have_http_status(:created)
      user = User.find_by(email: 'juan@ejemplo.com')

      patch "/api/v1/confirmations/#{user.confirmation_token}"
      expect(response).to have_http_status(:ok)

      post '/api/v1/sessions', params: { email: user.email, password: 'Password1' }
      expect(response).to have_http_status(:created)
      token = JSON.parse(response.body)['token']
      headers = { 'Authorization' => "Bearer #{token}" }

      post '/api/v1/stores', params: { store: { name: 'Tienda de Juan' } }, headers: headers
      expect(response).to have_http_status(:created)

      post '/api/v1/categories', params: { category: { name: 'Cereales' } }, headers: headers
      expect(response).to have_http_status(:created)
      store = user.reload.store
      category = store.categories.find_by(name: 'Cereales')

      branch = store.branches.find_by(is_main: true)
      post "/api/v1/branches/#{branch.id}/items",
        params: {
          item: { name: 'Avena', measure: 'kilo', cost: 15.0, current_quantity: 40, minimum_quantity: 10 },
          category_id: category.id
        },
        headers: headers
      expect(response).to have_http_status(:created)

      get '/api/v1/inventory', headers: headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['items'].first['name']).to eq('Avena')
      expect(body['items'].first['quantity_status']).to eq('complete')

      expect {
        post '/api/v1/inventory/exports', headers: headers
      }.to have_enqueued_job(InventoryExportJob)
      expect(response).to have_http_status(:created)
      export = InventoryExport.last

      perform_enqueued_jobs
      export.reload
      expect(export.status).to eq('completed')
      expect(export.file).to be_attached

      get "/api/v1/inventory/exports/#{export.id}/download", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Avena')
    end
  end

  describe 'permission flow' do
    let(:owner) { onboard_user }
    let(:store) { owner.store }
    let(:branch) { store.branches.find_by(is_main: true) }
    let(:category) { create(:category, store: store) }

    def member_headers(member)
      { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: member.id)}" }
    end

    it 'forbids a member without permissions from creating an item' do
      member = create(:user, store: store, password: 'Password1')
      role = create(:role, store: store, name: 'empleado', permissions: {})
      create(:branch_user, branch: branch, user: member, role: role)

      post "/api/v1/branches/#{branch.id}/items",
        params: { item: { name: 'No permitido', measure: 'kilo' }, category_id: category.id },
        headers: member_headers(member)

      expect(response).to have_http_status(:forbidden)
    end

    it 'allows a member with the items:create permission to create an item' do
      member = create(:user, store: store, password: 'Password1')
      permission = create(:global_permission, store: store, name: 'item-create', permissions: { 'item' => [ 'create' ] })
      member.update!(global_permission: permission)

      post "/api/v1/branches/#{branch.id}/items",
        params: { item: { name: 'Permitido', measure: 'kilo' }, category_id: category.id },
        headers: member_headers(member)

      expect(response).to have_http_status(:created)
    end
  end
end
