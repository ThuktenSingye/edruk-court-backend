# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let(:user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }

  path '/api/v1/signin' do
    post 'User login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string }
            },
            required: %w[email password]
          }
        }
      }

      context 'with valid credentials' do
        let(:user_params) do
          {
            user: {
              email: user.email,
              password: user.password
            }
          }
        end

        response '200', 'successful login' do
          it 'returns a successful response' do
            post user_session_path, params: user_params, as: :json
            expect(response).to have_http_status(:ok)
          end
        end
      end

      context 'with invalid credentials' do
        let(:user_params) do
          {
            user: {
              email: '',
              password: 'wrong_password'
            }
          }
        end

        response '401', 'unauthorized' do
          it 'returns an unauthorized response' do
            post user_session_path, params: user_params, as: :json
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
