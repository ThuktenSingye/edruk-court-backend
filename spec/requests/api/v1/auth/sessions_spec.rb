# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let(:user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }

  describe 'POST /api/v1/signin' do
    context 'with valid user attributes' do
      subject(:login_user) do
        post user_session_path, params: { user: valid_user }, as: :json
        response
      end

      let(:valid_user) { { email: user.email, password: user.password } }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'with invalid user attributes' do
      subject(:login_user) do
        post user_session_path, params: { user: invalid_user }
        response
      end

      let(:invalid_user) { { email: '', password: 'wrong_password' } }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
