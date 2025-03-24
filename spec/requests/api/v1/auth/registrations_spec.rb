# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  describe 'POST /api/v1/signup' do
    context 'with valid user attributes' do
      subject(:register_user) do
        post user_registration_path, params: { user: user }
        response
      end

      let(:user) do
        FactoryBot.attributes_for(:user, :password_confirmation).merge(
          profile_attributes: {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            cid_no: Faker::Number.number(digits: 11).to_s,
            phone_number: Faker::PhoneNumber.phone_number,
            gender: :male
          }
        )
      end

      it { is_expected.to have_http_status(:created) }
      it { expect { register_user }.to change(User, :count).by(1) }

      it 'assigns the default role to the user' do
        register_user
        created_user = User.last
        default_role = Role.find_by(name: 'User')
        expect(created_user.roles).to include(default_role)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'assign user with correct profile' do
        register_user
        created_user = User.last
        expect(created_user.profile).to have_attributes(
          first_name: user[:profile_attributes][:first_name],
          last_name: user[:profile_attributes][:last_name],
          cid_no: user[:profile_attributes][:cid_no],
          phone_number: user[:profile_attributes][:phone_number],
          gender: user[:profile_attributes][:gender].to_s
        )
      end
      # rubocop:enable RSpec/ExampleLength
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
