# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::V1::Auth::Confirmation', type: :request do
  path '/api/v1/auth/confirmation' do
    get 'Confirm users account' do
      tags 'Authentication'
      produces 'application/json'

      parameter name: :confirmation_token, in: :query, type: :string, required: true,
                description: 'Confirmation token sent to users email'

      let!(:user) { FactoryBot.create(:user, confirmed_at: nil) }

      context 'with valid token' do
        let(:confirmation_token) { user.confirmation_token }

        response '200', 'account successfully confirmed' do
          it 'returns ok status' do
            get user_confirmation_path, params: { confirmation_token: confirmation_token }
            expect(response).to have_http_status(:ok)
          end

          it 'confirms the users' do
            get user_confirmation_path, params: { confirmation_token: confirmation_token }
            expect(user.reload).to be_confirmed
          end
        end
      end

      context 'with invalid token' do
        let(:confirmation_token) { 'invalid_token' }

        response '422', 'unprocessable entity' do
          it 'returns unprocessable entity status' do
            get user_confirmation_path, params: { confirmation_token: confirmation_token }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'with expired token' do
        let(:confirmation_token) { user.confirmation_token }

        before do
          user.update(confirmation_sent_at: 4.days.ago)
        end

        response '422', 'unprocessable entity' do
          it 'returns unprocessable entity status' do
            get user_confirmation_path, params: { confirmation_token: confirmation_token }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
