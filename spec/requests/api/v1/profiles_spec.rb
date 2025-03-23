# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Profiles', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let(:user) { FactoryBot.create(:user, :court_user, court: court, confirmed_at: Time.zone.now) }
  let!(:profile) { FactoryBot.create(:profile, user: user) }

  before do
    sign_in user
    subdomain court.subdomain
  end

  describe 'GET /show' do
    context 'when user record exists' do
      subject(:get_profile) do
        get api_v1_profile_path(profile)
        response
      end

      it { is_expected.to have_http_status :ok }
    end
  end

  describe 'PUT /update' do
    context 'with valid profile params' do
      subject(:update_profile) do
        put api_v1_profile_path(profile), params: { profile: valid_profile_params }
        response
      end

      let(:valid_profile_params) do
        {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          cid_no: Faker::Number.number(digits: 11).to_s,
          phone_number: Faker::PhoneNumber.phone_number,
          house_no: Faker::Number.number(digits: 5).to_s,
          thram_no: Faker::Number.number(digits: 5).to_s,
          age: 10,
          gender: :male,
          addresses_attributes: [
            {
              dzongkhag: Faker::Address.state,
              gewog: Faker::Address.city,
              street_address: Faker::Address.street_address,
              address_type: :present
            },
            {
              dzongkhag: Faker::Address.state,
              gewog: Faker::Address.city,
              street_address: Faker::Address.street_address,
              address_type: :permanent
            }
          ]
        }
      end

      it { is_expected.to have_http_status :ok }
      it { expect { update_profile }.not_to change(Profile, :count) }

      # rubocop:disable RSpec/ExampleLength
      it 'updates the profile with correct attributes' do
        update_profile
        expect(Profile.last).to have_attributes(
          first_name: valid_profile_params[:first_name],
          last_name: valid_profile_params[:last_name],
          cid_no: valid_profile_params[:cid_no],
          phone_number: valid_profile_params[:phone_number],
          house_no: valid_profile_params[:house_no],
          thram_no: valid_profile_params[:thram_no],
          age: valid_profile_params[:age],
          gender: valid_profile_params[:gender].to_s
        )
        # rubocop:enable RSpec/ExampleLength
      end
    end

    context 'with invalid profile params' do
      subject(:update_profile) do
        put api_v1_profile_path(profile), params: { profile: invalid_profile_params }
        response
      end

      let(:invalid_profile_params) { FactoryBot.attributes_for(:profile, :invalid_profile_params) }

      it { is_expected.to have_http_status :unprocessable_entity }
      it { expect { update_profile }.not_to change(Profile, :count) }

      it 'assigns the correct profile' do
        update_profile
        expect(assigns(:profile)).to eq(profile)
      end
    end
  end
end
