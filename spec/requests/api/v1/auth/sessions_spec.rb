require 'rails_helper'

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe 'POST /api/v1/signin' do
    context 'when valid attributes' do
      subject(:login_user) do
        post user_session_path, params: { user: valid_user }, as: :json
        response
      end

      let(:valid_user) { { email: user.email, password: user.password } }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when valid attributes' do
      subject(:login_user) do
        post user_session_path, params: { user: invalid_user }
        response
      end

      let(:invalid_user) { { email: "", password: 'wrong_password' } }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
