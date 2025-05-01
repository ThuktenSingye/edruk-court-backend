# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/LetSetup, Style/GlobalVars
RSpec.describe CasePolicy, type: :policy do
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: $default_account) }

  describe 'permissions' do
    context 'when role is registrar' do
      subject { described_class.new(registrar_user, court_case) }

      let(:registrar_user) { FactoryBot.create(:user, :registrar) }
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: registrar_user,
                                             role: Role.find_by(name: 'Registrar'))
      end

      it { is_expected.to permit_actions(%i[index update create statistics]) }
    end

    context 'when role is judge' do
      subject { described_class.new(judge_user, court_case) }

      let(:judge_user) { FactoryBot.create(:user, :judge) }
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: judge_user, role: Role.find_by(name: 'Judge'))
      end

      it { is_expected.to permit_actions(%i[index statistics]) }
    end

    context 'when role is clerk' do
      subject { described_class.new(clerk_user, court_case) }

      let(:clerk_user) { FactoryBot.create(:user, :clerk) }
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
      end

      it { is_expected.to permit_actions(%i[index]) }
    end
  end
  # rubocop:enable RSpec/LetSetup, Style/GlobalVars
end
