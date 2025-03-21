# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  describe 'POST /api/v1/signup' do
    context 'with valid user attributes' do
      subject(:register_user) do
        post user_registration_path, params: { user: user }
        response
      end

      let(:user) { FactoryBot.attributes_for(:user, :password_confirmation) }

      it { is_expected.to have_http_status(:created) }
      it { expect { register_user }.to change(User, :count).by(1) }

      it 'assigns the default role to the user' do
        register_user
        created_user = User.last
        default_role = Role.find_by(name: 'User')
        expect(created_user.roles).to include(default_role)
      end
    end

    context 'with invalid user attributes' do
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
