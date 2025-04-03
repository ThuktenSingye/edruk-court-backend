# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::V1::Addresses', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let(:user) { FactoryBot.create(:user, :court_user, court: court, confirmed_at: Time.zone.now) }
  let!(:profile) { FactoryBot.create(:profile, user: user) }
  let(:auth_token) { auth_headers(user)['Authorization'] }

  before do
    sign_in user
  end

  path '/api/v1/users/{user_id}/profile/addresses' do
    parameter name: :user_id, in: :path, type: :integer, description: 'User ID'

    post 'Create Address' do
      tags 'Addresses'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :address_params, in: :body, schema: {
        type: :object,
        properties: {
          address: {
            type: :object,
            properties: {
              dzongkhag: { type: :string },
              gewog: { type: :string },
              street_address: { type: :string },
              address_type: { type: :string }
            },
            required: %w[dzongkhag gewog street_address address_type]
          }
        },
        required: ['address']
      }

      context 'with valid params' do
        subject(:create_address) do
          post api_v1_user_profile_addresses_path(user, profile), params: valid_address_params.to_json,
                                                                  headers: { 'CONTENT_TYPE' => 'application/json',
                                                                             'Authorization' => auth_token }
          response
        end

        let(:valid_address_params) { FactoryBot.attributes_for(:address) }

        response '201', 'Address created' do
          it { is_expected.to have_http_status :created }
          it { expect { create_address }.to change(Address, :count).by(1) }

          it 'creates an address with correct attributes' do
            create_address
            expect(Address.last).to have_attributes(
              dzongkhag: valid_address_params[:dzongkhag], gewog: valid_address_params[:gewog],
              address_type: valid_address_params[:address_type].to_s
            )
          end
        end
      end

      context 'with invalid params' do
        subject(:create_address) do
          post api_v1_user_profile_addresses_path(user), params: invalid_address_params.to_json,
                                                         headers: { 'CONTENT_TYPE' => 'application/json',
                                                                    'Authorization' => auth_token }
          response
        end

        let(:invalid_address_params) { FactoryBot.attributes_for(:address, :invalid_address_params) }

        response '422', 'Invalid request' do
          it { is_expected.to have_http_status :unprocessable_entity }
          it { expect { create_address }.not_to change(Address, :count) }
        end
      end
    end
  end
end
