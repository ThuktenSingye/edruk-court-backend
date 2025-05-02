# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::V1::Auth::Passwords', type: :request do
  let!(:user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }
  let!(:reset_password_token) { generate_reset_password_token(user) }

  def generate_reset_password_token(user)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    user.reset_password_token = hashed
    user.reset_password_sent_at = Time.zone.now
    user.save
    raw
  end

  path '/api/v1/auth/password' do
    put 'Reset users password' do
      tags 'Authentication'
      consumes 'application/json'

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string },
              password_confirmation: { type: :string },
              reset_password_token: { type: :string }
            },
            required: %w[email password password_confirmation reset_password_token]
          }
        }
      }

      produces 'application/json'
      context 'with valid attributes' do
        subject(:password_reset) do
          put user_password_path, params: user_params, as: :json
          response
        end

        let(:valid_user_attributes) do
          {
            email: user.email,
            password: 'new_password',
            password_confirmation: 'new_password',
            reset_password_token: reset_password_token
          }
        end
        let(:user_params) { { user: valid_user_attributes } }

        response '200', 'password successfully reset' do
          it { is_expected.to have_http_status :ok }
          it { expect { password_reset }.not_to change(User, :count) }

          it 'changes the users password' do
            password_reset
            user.reload
            expect(user).to be_valid_password('new_password')
          end
        end
      end

      context 'with invalid attributes' do
        subject(:password_reset) do
          put user_password_path, params: user_params, as: :json
          response
        end

        let(:invalid_user_attributes) do
          {
            email: user.email,
            password: 'new_password',
            password_confirmation: 'wrong_password',
            reset_password_token: reset_password_token
          }
        end
        let(:user_params) { { user: invalid_user_attributes } }

        response '422', 'unprocessable entity' do
          it { is_expected.to have_http_status :unprocessable_entity }

          it 'does not change the users password' do
            password_reset
            user.reload
            expect(user).not_to be_valid_password('new_password')
          end
        end
      end
    end
  end
end
