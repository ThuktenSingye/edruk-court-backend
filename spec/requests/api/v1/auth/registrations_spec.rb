# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  path '/api/v1/signup' do
    post 'User registration' do
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
              profile_attributes: {
                type: :object,
                properties: {
                  first_name: { type: :string },
                  last_name: { type: :string },
                  cid_no: { type: :string },
                  phone_number: { type: :string },
                  gender: { type: :string }
                },
                required: %w[first_name last_name cid_no phone_number gender]
              }
            },
            required: %w[email password password_confirmation profile_attributes]
          }
        }
      }

      produces 'application/json'
      context 'with valid user attributes' do
        subject(:register_user) do
          post user_registration_path, params: user_params, as: :json
          response
        end

        let(:valid_user_attributes) do
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

        let(:user_params) { { user: valid_user_attributes } }

        response '201', 'user created' do
          it { expect { register_user }.to change(User, :count).by(1) }
          it { is_expected.to have_http_status(:created) }

          it 'assigns the default role' do
            register_user
            created_user = User.last
            default_role = Role.find_by(name: 'User')
            expect(created_user.roles).to include(default_role)
          end

          # rubocop:disable RSpec/ExampleLength
          it 'creates user with correct profile' do
            register_user
            created_user = User.last
            expect(created_user.profile).to have_attributes(
              first_name: valid_user_attributes[:profile_attributes][:first_name],
              last_name: valid_user_attributes[:profile_attributes][:last_name],
              cid_no: valid_user_attributes[:profile_attributes][:cid_no],
              phone_number: valid_user_attributes[:profile_attributes][:phone_number],
              gender: valid_user_attributes[:profile_attributes][:gender].to_s
            )
            # rubocop:enable RSpec/ExampleLength
          end
        end
      end

      context 'with invalid user attributes' do
        subject(:register_user) do
          post user_registration_path, params: user_params, as: :json
          response
        end

        let(:invalid_user_attributes) { FactoryBot.attributes_for(:user, :invalid_user) }
        let(:user_params) { { user: invalid_user_attributes } }

        response '422', 'unprocessable entity' do
          it { is_expected.to have_http_status(:unprocessable_entity) }
          it { expect { register_user }.not_to change(User, :count) }
        end
      end
    end
  end
end
