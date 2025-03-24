# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfilePolicy, type: :policy do
  subject { described_class.new(user, profile) }

  let(:user) { FactoryBot.create(:user) }
  let(:profile) { FactoryBot.create(:profile, user: user) }

  describe 'permissions' do
    context 'when role is user' do
      it { is_expected.to permit_actions(%i[show update]) }
    end

    context 'when role is admin' do
      let(:admin_role) { FactoryBot.create(:role, :admin) }
      let(:admin) { FactoryBot.create(:user) { |user| user.roles << admin_role } }

      it { is_expected.to permit_actions(%i[show update]) }
    end
  end
end
