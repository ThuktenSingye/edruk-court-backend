# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }

  describe 'permissions' do
    context 'when role is registrar' do
      subject { described_class.new(admin, user) }

      let(:user) { FactoryBot.create(:user) }

      it { is_expected.to permit_actions(%i[show create update]) }
    end
  end
end
