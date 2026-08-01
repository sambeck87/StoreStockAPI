require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :controller do
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a user with a confirmation token and enqueues the confirmation mailer' do
        expect {
          post :create, params: {
            user: {
              email: 'nuevo@example.com',
              full_name: 'Nuevo Usuario',
              password: 'Password1',
              password_confirmation: 'Password1'
            }
          }
        }.to change(User, :count).by(1)
         .and have_enqueued_mail(ConfirmationMailer, :confirmation)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to be_present

        user = User.last
        expect(user.confirmation_token).to be_present
        expect(user.confirmation_sent_at).to be_present
        expect(user.confirmed_at).to be_nil
        expect(user.store).to be_nil
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity when password confirmation is missing' do
        expect {
          post :create, params: {
            user: { email: 'x@example.com', full_name: 'X', password: 'Password1' }
          }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns unprocessable entity when the email is already taken' do
        create(:user, email: 'duplicado@example.com')

        post :create, params: {
          user: {
            email: 'duplicado@example.com',
            full_name: 'X',
            password: 'Password1',
            password_confirmation: 'Password1'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns unprocessable entity when the password is too weak' do
        post :create, params: {
          user: {
            email: 'debil@example.com',
            full_name: 'X',
            password: 'short',
            password_confirmation: 'short'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
