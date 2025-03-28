# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe HearingPolicy, type: :policy do
  let(:court) { FactoryBot.create(:court) }
  let!(:user) { FactoryBot.create(:user, :court_user, court: court, confirmed_at: Time.zone.now) }
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: court) }
  let(:hearing_type) { FactoryBot.create(:hearing_type) }
  let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }

  describe 'permissions' do
    context 'when role is registrar' do
      subject { described_class.new(user, hearing) }

      let(:user) { FactoryBot.create(:user, :registrar) }

      it { is_expected.to permit_actions(%i[index update create]) }
    end

    context 'when role is judge' do
      subject { described_class.new(user, hearing) }

      let(:user) { FactoryBot.create(:user, :judge) }

      it { is_expected.to permit_actions(%i[index update]) }
    end

    context 'when role is judge, create is not allowed' do
      subject { described_class.new(user, hearing) }

      let(:user) { FactoryBot.create(:user, :judge) }

      it { is_expected.not_to permit_action(%i[create]) }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
