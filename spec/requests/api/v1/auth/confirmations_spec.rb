# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Confirmation', type: :request do
  let!(:user) { FactoryBot.create(:user, confirmed_at: nil) }

  describe 'GET /show' do
    context 'with valid token' do
      subject(:confirm_user) do
        get user_confirmation_path, params: { confirmation_token: user.confirmation_token }
        response
      end

      it { is_expected.to have_http_status :ok }

      it 'confirms the user' do
        user.confirm
        expect(user.reload).to be_confirmed
      end
    end

    context 'with invalid token' do
      subject do
        get user_confirmation_path, params: { confirmation_token: 'invalid_token' }
        response
      end

      it { is_expected.to have_http_status :unprocessable_entity }
    end

    context 'with expired token' do
      subject do
        get user_confirmation_path, params: { confirmation_token: user.confirmation_token }
        response
      end

      before do
        user.update(confirmation_sent_at: 4.days.ago)
      end

      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end
end
