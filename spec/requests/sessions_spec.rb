require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  describe 'POST #create' do
    let(:store) { create(:store) }
    let(:user) { create(:user, store: store, password: 'Password1', confirmation_token: nil) }

    context 'with valid credentials' do
      it 'returns a JWT token' do
        post :create, params: { email: user.email, password: 'Password1' }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized' do
        post :create, params: { email: user.email, password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
