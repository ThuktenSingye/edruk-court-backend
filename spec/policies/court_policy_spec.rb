# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourtPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }

  describe 'permissions' do
    context 'when role is registrar' do
      subject { described_class.new(admin, court) }

      let(:court) { FactoryBot.create(:court) }

      it { is_expected.to permit_actions(%i[index show create update]) }
    end
  end
end
