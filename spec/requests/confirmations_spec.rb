require 'rails_helper'

RSpec.describe Api::V1::ConfirmationsController, type: :controller do
  describe 'PATCH #update' do
    let(:user) do
      create(:user, store: nil, confirmation_token: 'abc123', confirmation_sent_at: Time.current)
    end

    context 'with a valid token' do
      it 'confirms the email and clears the token' do
        patch :update, params: { id: user.confirmation_token }

        expect(response).to have_http_status(:ok)

        user.reload
        expect(user.confirmation_token).to be_nil
        expect(user.confirmed_at).to be_present
      end
    end

    context 'with an invalid token' do
      it 'returns not_found' do
        patch :update, params: { id: 'token-invalido' }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
