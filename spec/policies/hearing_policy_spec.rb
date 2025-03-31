# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/LetSetup
RSpec.describe HearingPolicy, type: :policy do
  let(:court) { FactoryBot.create(:court) }
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: court) }

  describe 'permissions' do
    context 'when role is registrar and there is no hearing' do
      subject { described_class.new(registrar_user, new_hearing) }

      let(:registrar_user) { FactoryBot.create(:user, :registrar) }
      let(:hearing_type) { FactoryBot.build(:hearing_type) }
      let(:new_hearing) { FactoryBot.build(:hearing, case: court_case) }

      it { is_expected.to permit_actions(%i[index update create]) }
    end

    context 'when role is registrar and hearing is miscellaneous' do
      subject { described_class.new(registrar_user, miscellaneous_hearing) }

      let(:registrar_user) { FactoryBot.create(:user, :registrar) }
      let(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
      let!(:miscellaneous_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
      end

      it { is_expected.to permit_actions(%i[index create update]) }
    end

    context 'when role is registrar and hearing is preliminary' do
      subject { described_class.new(registrar_user, preliminary_hearing) }

      let(:registrar_user) { FactoryBot.create(:user, :registrar) }
      let(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
      let!(:miscellaneous_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
      end
      let(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let(:preliminary_hearing) do
        FactoryBot.build(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
      end

      it { is_expected.to permit_actions(:index) }
      it { is_expected.to forbid_actions(%i[create update]) }
    end

    context 'when role is clerk and hearing is miscellaneous' do
      subject { described_class.new(registrar_user, miscellaneous_hearing) }

      let(:registrar_user) { FactoryBot.create(:user, :clerk) }
      let(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
      let!(:miscellaneous_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
      end

      it { is_expected.to permit_actions(:index) }
      it { is_expected.to forbid_actions(%i[create update]) }
    end

    context 'when role is judge and hearing is preliminary' do
      subject { described_class.new(judge_user, preliminary_hearing) }

      let(:judge_user) { FactoryBot.create(:user, :judge) }
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: judge_user,
                                             role: Role.find_by(name: 'Judge'))
      end

      let(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let(:preliminary_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
      end

      it { is_expected.to permit_actions(%i[update create]) }
    end

    context 'when role is judge and hearing is not either miscellanoues or prelimi' do
      subject { described_class.new(judge_user, judgement_hearing) }

      let(:judge_user) { FactoryBot.create(:user, :judge) }
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: judge_user,
                                             role: Role.find_by(name: 'Judge'))
      end

      let(:hearing_type) { FactoryBot.create(:hearing_type) }
      let(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }

      let(:judgement_type) { FactoryBot.create(:hearing_type, :judgement) }
      let(:judgement_hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: judgement_type) }

      it { is_expected.to permit_actions(%i[update create]) }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
end
