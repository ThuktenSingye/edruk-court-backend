# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddressPolicy, type: :policy do
  subject { described_class.new(user, address) }

  let(:user) { FactoryBot.create(:user) }
  let(:profile) { FactoryBot.create(:profile) }
  let(:address) { FactoryBot.create(:address, profile: profile) }
  let(:admin_role) { FactoryBot.create(:role, :admin) }
  let(:admin) { FactoryBot.create(:user) { |user| user.roles << admin_role } }

  describe 'permissions' do
    context 'when role is user' do
      let(:user) { profile.user }

      it { is_expected.to permit_action(:create) }
    end

    context 'when role is admin' do
      let(:user) { admin }

      it { is_expected.to permit_action(:create) }
    end
  end
end
