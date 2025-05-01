# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
RSpec.describe HearingSchedulePolicy, type: :policy do
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: $default_account) }
  let(:hearing_type) { FactoryBot.create(:hearing_type) }
  let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }

  let(:registrar_user) { FactoryBot.create(:user, :registrar, confirmed_at: Time.zone.now) }
  let(:judge_user) { FactoryBot.create(:user, :judge, confirmed_at: Time.zone.now) }
  let(:clerk_user) { FactoryBot.create(:user, :clerk, confirmed_at: Time.zone.now) }

  # let!(:hearing_schedule) { FactoryBot.create(:hearing_schedule, hearing: hearing, scheduled_by: clerk_user) }

  describe 'permissions' do
    context 'when role is registrar' do
      subject { described_class.new(registrar_user, hearing_schedule) }

      let(:hearing_schedule) { FactoryBot.create(:hearing_schedule, hearing: hearing) }

      it { is_expected.to permit_actions(%i[index]) }
    end

    context 'when role is judge' do
      subject { described_class.new(judge_user, hearing_schedule) }

      let(:hearing_schedule) { FactoryBot.create(:hearing_schedule, hearing: hearing) }

      it { is_expected.to permit_actions(%i[index]) }
    end

    context 'when role is clerk and hearing is miscellaneous' do
      subject { described_class.new(clerk_user, hearing_schedule) }

      let(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
      let(:miscellaneous_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
      end
      let(:hearing_schedule) do
        FactoryBot.create(:hearing_schedule, hearing: miscellaneous_hearing, scheduled_by: registrar_user)
      end
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
                                             role: Role.find_by(name: 'Clerk'))
      end

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end

    context 'when role is registrar and the hearing is preliminary' do
      subject { described_class.new(registrar_user, hearing_schedule) }

      let(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let(:preliminary_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
      end
      let(:hearing_schedule) do
        FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: registrar_user)
      end

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end

    context 'when role is clerk and hearing is preliminary' do
      subject { described_class.new(clerk_user, hearing_schedule) }

      let(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let!(:preliminary_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
      end
      let!(:hearing_schedule) do
        FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: registrar_user)
      end
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
                                             role: Role.find_by(name: 'Clerk'))
      end

      it { is_expected.to permit_actions(%i[update destroy]) }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
end
