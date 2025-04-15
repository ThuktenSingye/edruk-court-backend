# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
RSpec.describe NotePolicy, type: :policy do
  let(:court) { create(:court) }
  let(:case_type) { create(:case_type) }
  let(:case_subtype) { create(:case_subtype, case_type: case_type) }
  let!(:court_case) { create(:case, case_subtype: case_subtype, court: court) }

  let(:registrar_user) { create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }
  let(:judge_user) { create(:user, :judge, court: court, confirmed_at: Time.zone.now) }
  let(:clerk_user) { create(:user, :clerk, court: court, confirmed_at: Time.zone.now) }

  describe 'permissions' do
    context 'when role is registrar and hearing is pre-stage' do
      subject { described_class.new(registrar_user, note) }

      let(:hearing_type) { create(:hearing_type, :miscellaneous) }
      let(:hearing) { create(:hearing, case: court_case, hearing_type: hearing_type) }
      let(:note) { create(:note, user: registrar_user, hearing: hearing) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context 'when role is registrar and hearing is post-stage' do
      subject { described_class.new(registrar_user, note) }

      let(:hearing_type) { create(:hearing_type, :preliminary) }
      let(:hearing) { create(:hearing, case: court_case, hearing_type: hearing_type) }
      let(:note) { create(:note, user: registrar_user, hearing: hearing) }

      it { is_expected.to forbid_actions(%i[index create update destroy]) }
    end

    context 'when role is judge and hearing is post-stage' do
      subject { described_class.new(judge_user, note) }

      let(:hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }
      let(:note) { FactoryBot.create(:note, user: judge_user, hearing: hearing) }

      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: judge_user,
                                             role: Role.find_by(name: 'Judge'))
      end

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context 'when role is judge and hearing is pre-stage' do
      subject { described_class.new(judge_user, note) }

      let(:hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
      let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }
      let(:note) { FactoryBot.create(:note, user: judge_user, hearing: hearing) }

      it { is_expected.to forbid_actions(%i[index create update destroy]) }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
end
