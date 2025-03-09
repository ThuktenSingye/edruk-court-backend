require 'rails_helper'

RSpec.describe "Api::V1::Users::Registrations", type: :request do
  describe 'POST /api/v1/signup' do
    context 'when valid attributes' do
      subject(:register_user) do
        post user_registration_path, params: { user: user }
        response
      end

      let(:user) { FactoryBot.attributes_for(:user, :password_confirmation) }

      it { is_expected.to have_http_status(:created) }
      it { expect { register_user }.to change(User, :count).by(1) }
    end

    context 'when valid attributes' do
      subject(:register_user) do
        post user_registration_path, params: { user: user }
        response
      end

      let(:user) { FactoryBot.attributes_for(:user, :invalid_user) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { expect { register_user }.not_to change(User, :count) }
    end
  end
end
