# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Passwords', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:reset_password_token) { generate_reset_password_token(user) }

  def generate_reset_password_token(user)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    user.reset_password_token = hashed
    user.reset_password_sent_at = Time.zone.now
    user.save
    raw
  end

  context 'when valid attributes' do
    subject(:reset_user_password) do
      put user_password_path, params: { user: valid_user_attributes }
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

    it { is_expected.to have_http_status(:ok) }
    it { expect { reset_user_password }.not_to change(User, :count) }

    it 'changes the user password' do
      reset_user_password
      user.reload
      expect(user).to be_valid_password('new_password')
    end
  end

  context 'when invalid attributes' do
    subject(:reset_user_password) do
      put user_password_path, params: { user: invalid_user_attributes }
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

    it { is_expected.to have_http_status(:unprocessable_entity) }

    it 'does not change the user password' do
      reset_user_password
      user.reload
      expect(user).not_to be_valid_password('new_password')
    end
  end
end
