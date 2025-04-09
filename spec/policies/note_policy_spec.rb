require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
RSpec.describe NotePolicy, type: :policy do
  let(:court) { FactoryBot.create(:court) }
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: court) }


  let(:registrar_user) { FactoryBot.create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }
  let(:judge_user) { FactoryBot.create(:user, :judge, court: court, confirmed_at: Time.zone.now) }
  let(:clerk_user) { FactoryBot.create(:user, :clerk, court: court, confirmed_at: Time.zone.now) }

  describe 'permissions' do
    context 'when role is registrar and hearing is pre-stage' do
      subject { described_class.new(registrar_user, note) }

      let(:hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
      let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }
      let(:note) { FactoryBot.create(:note, user: registrar_user, hearing: hearing) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context 'when role is registrar and hearing is post-stage' do
      subject { described_class.new(registrar_user, note) }

      let(:hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }
      let(:note) { FactoryBot.create(:note, user: registrar_user, hearing: hearing) }

      it { is_expected.to forbid_actions(%i[index create update destroy]) }
    end

    context 'when role is judge and hearing is post-stage' do
      subject { described_class.new(judge_user, note) }

      let(:hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }
      let(:note) { FactoryBot.create(:note, user: judge_user, hearing: hearing) }

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
