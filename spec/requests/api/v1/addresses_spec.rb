# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Addresses', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let(:user) { FactoryBot.create(:user, :court_user, court: court, confirmed_at: Time.zone.now) }
  let!(:profile) { FactoryBot.create(:profile, user: user) }

  before do
    sign_in user
  end

  describe 'POST /create' do
    let(:valid_address_params) { FactoryBot.attributes_for(:address) }
    let(:invalid_address_params) { FactoryBot.attributes_for(:address, :invalid_address_params) }

    context 'with valid params' do
      subject(:create_address) do
        post api_v1_user_profile_addresses_path(user, profile), params: { address: valid_address_params }
        response
      end

      it { is_expected.to have_http_status :created }
      it { expect { create_address }.to change(Address, :count).by(1) }

      it 'create an address with correct attributes' do
        create_address
        expect(Address.last).to have_attributes(
          dzongkhag: valid_address_params[:dzongkhag], gewog: valid_address_params[:gewog],
          address_type: valid_address_params[:address_type].to_s
        )
      end
    end

    context 'with invalid address params' do
      subject(:create_address) do
        post api_v1_user_profile_addresses_path(user), params: { address: invalid_address_params }
        response
      end

      it { is_expected.to have_http_status :unprocessable_entity }
      it { expect { create_address }.not_to change(Address, :count) }
    end
  end
end
