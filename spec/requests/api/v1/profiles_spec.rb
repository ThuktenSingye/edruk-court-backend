# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe 'Api::V1::Profiles', type: :request do
  let!(:user) { create(:user, confirmed_at: Time.zone.now) }
  let!(:profile) { create(:profile, user: user) }
  let(:auth_token) { auth_headers(user)['Authorization'] }

  before do
    sign_in user
  end

  path '/api/v1/users/{user_id}/profile' do
    parameter name: :user_id, in: :path, type: :integer, description: 'User ID'

    get 'Get User Profile' do
      tags 'Profiles'
      security [Bearer: []]
      produces 'application/json'

      context 'with valid params' do
        response '200', 'Profile found' do
          subject(:get_profile) do
            get api_v1_user_profile_path(user),
                headers: { 'ACCEPT' => 'application/json', 'Authorization' => auth_token }
            response
          end

          it { is_expected.to have_http_status(:ok) }

          it 'get correct profile attributess' do
            get_profile
            user_profile = user.profile.reload
            expect(api_response['data']).to include(
              'first_name' => user_profile.first_name,
              'last_name' => user_profile.last_name,
              'cid_no' => user_profile.cid_no,
              'phone_number' => user_profile.phone_number,
              'house_no' => user_profile.house_no,
              'thram_no' => user_profile.thram_no,
              'age' => user_profile.age,
              'gender' => user_profile.gender.humanize
            )
          end
        end
      end
    end

    path '/api/v1/users/{user_id}/profile' do
      put 'Update User Profile' do
        tags 'Profiles'
        security [Bearer: []]
        consumes 'application/json'
        produces 'application/json'
        parameter name: :profile_params, in: :body, schema: {
          type: :object,
          properties: {
            profile: {
              type: :object,
              properties: {
                first_name: { type: :string },
                last_name: { type: :string },
                cid_no: { type: :string },
                phone_number: { type: :string },
                house_no: { type: :string },
                thram_no: { type: :string },
                age: { type: :integer },
                gender: { type: :string },
                addresses_attributes: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      dzongkhag: { type: :string },
                      gewog: { type: :string },
                      street_address: { type: :string },
                      address_type: { type: :string }
                    }
                  }
                }
              },
              required: %w[first_name last_name cid_no phone_number]
            }
          },
          required: ['profile']
        }

        context 'with valid params' do
          subject(:update_profile) do
            put api_v1_user_profile_path(user), params: profile_params.to_json,
                                                headers: { 'CONTENT_TYPE' => 'application/json',
                                                           'Authorization' => auth_token }
            response
          end

          let(:profile_params) do
            {
              profile: {
                first_name: 'UpdatedName',
                last_name: 'UpdatedLastName',
                cid_no: '12345678901',
                phone_number: '1234567890',
                house_no: '12345',
                thram_no: '54321',
                age: 30,
                gender: 'male'
              }
            }
          end

          response '200', 'Profile updated' do
            it { is_expected.to have_http_status :ok }

            it 'updates the profile' do
              update_profile
              user_profile = Profile.last.reload
              expect(api_response['data']).to include(
                'first_name' => user_profile.first_name,
                'last_name' => user_profile.last_name,
                'cid_no' => user_profile.cid_no,
                'phone_number' => user_profile.phone_number,
                'house_no' => user_profile.house_no,
                'thram_no' => user_profile.thram_no,
                'age' => user_profile.age,
                'gender' => user_profile.gender.humanize
              )
            end
          end
        end

        context 'with invalid params' do
          subject(:update_profile) do
            put api_v1_user_profile_path(user), params: profile_params.to_json,
                                                headers: { 'CONTENT_TYPE' => 'application/json',
                                                           'Authorization' => auth_token }
            response
          end

          let(:profile_params) do
            {
              profile: {
                first_name: ''
              }
            }
          end

          response '422', 'Invalid request' do
            it { is_expected.to have_http_status :unprocessable_entity }

            it 'assign original profile' do
              update_profile
              expect(assigns(:profile)).to eq(profile)
            end
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
