# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
RSpec.describe CaseDocumentPolicy, type: :policy do
  # let!(:court) { create(:court) }
  let(:case_type) { create(:case_type) }
  let(:case_subtype) { create(:case_subtype, case_type: case_type) }
  let!(:court_case) { create(:case, case_subtype: case_subtype, court: $default_account) }
  let(:hearing_type) { create(:hearing_type) }
  let(:hearing) { create(:hearing, case: court_case, hearing_type: hearing_type) }
  let(:miscellaneous_hearing_type) { create(:hearing_type, :miscellaneous) }
  let!(:miscellaneous_hearing) { create(:hearing, hearing_type: miscellaneous_hearing_type, case: court_case) }

  let(:registrar_user) { create(:user, :registrar, confirmed_at: Time.zone.now) }
  let(:judge_user) { create(:user, :judge, confirmed_at: Time.zone.now) }
  let(:clerk_user) { create(:user, :clerk, confirmed_at: Time.zone.now) }

  describe 'permissions' do
    context 'when role is registrar and hearing is pre hearing' do
      subject { described_class.new(registrar_user, case_document) }

      let(:case_document) { create(:case_document, :with_document, hearing: miscellaneous_hearing) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context 'when role is registrar and hearing is post hearing' do
      subject { described_class.new(registrar_user, case_document) }

      let(:case_document) { create(:case_document, :with_document, hearing: hearing) }

      it { is_expected.to forbid_actions(%i[create update destroy]) }
    end

    context 'when role is judge and the hearing is pre hearing' do
      subject { described_class.new(judge_user, case_document) }

      let(:case_document) { create(:case_document, :with_document, hearing: miscellaneous_hearing) }

      it { is_expected.to forbid_actions(%i[create update destroy]) }
    end

    context 'when role is judge and the hearing is post hearing' do
      subject { described_class.new(judge_user, case_document) }

      let(:case_document) { create(:case_document, :with_document, hearing: hearing) }
      let!(:case_participant) do
        create(:case_participant, case: court_case, user: judge_user,
                                  role: Role.find_by(name: 'Judge'))
      end

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
end
