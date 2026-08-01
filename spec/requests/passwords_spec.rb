require 'rails_helper'

RSpec.describe Api::V1::PasswordsController, type: :controller do
  describe 'POST #reset' do
    context 'when the user exists' do
      let(:user) { create(:user, store: nil) }

      it 'sets a reset token and enqueues the reset mailer' do
        expect {
          post :reset, params: { email: user.email }
        }.to have_enqueued_mail(PasswordsMailer, :reset)

        expect(response).to have_http_status(:no_content)
        expect(user.reload.reset_password_token).to be_present
        expect(user.reload.reset_password_sent_at).to be_present
      end
    end

    context 'when the user does not exist' do
      it 'returns no content without enqueuing the mailer' do
        expect {
          post :reset, params: { email: 'no-existe@example.com' }
        }.not_to have_enqueued_mail(PasswordsMailer, :reset)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'PUT #update' do
    let(:user) do
      create(:user, store: nil, reset_password_token: 'reset-token', reset_password_sent_at: Time.current)
    end

    context 'with a valid and fresh token' do
      it 'updates the password and clears the token' do
        put :update, params: {
          token: user.reset_password_token,
          password: 'NewPassword1',
          password_confirmation: 'NewPassword1'
        }

        expect(response).to have_http_status(:ok)

        user.reload
        expect(user.authenticate('NewPassword1')).to be_truthy
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
      end
    end

    context 'with an expired token' do
      before { user.update!(reset_password_sent_at: 2.hours.ago) }

      it 'returns unauthorized' do
        put :update, params: {
          token: user.reset_password_token,
          password: 'NewPassword1',
          password_confirmation: 'NewPassword1'
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with an invalid token' do
      it 'returns unauthorized' do
        put :update, params: {
          token: 'token-invalido',
          password: 'NewPassword1',
          password_confirmation: 'NewPassword1'
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a password that fails validation' do
      it 'returns unprocessable entity' do
        put :update, params: {
          token: user.reset_password_token,
          password: 'short',
          password_confirmation: 'short'
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #confirm_email' do
    let(:user) do
      create(:user, store: nil, confirmation_token: 'confirm-token', confirmation_sent_at: Time.current)
    end

    context 'with a valid token' do
      it 'confirms the email and returns a session token' do
        post :confirm_email, params: { token: user.confirmation_token }

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        expect(body['token']).to be_present

        user.reload
        expect(user.confirmation_token).to be_nil
        expect(user.confirmed_at).to be_present
      end
    end

    context 'with an invalid token' do
      it 'returns not_found' do
        post :confirm_email, params: { token: 'token-invalido' }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
