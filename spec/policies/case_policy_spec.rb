# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasePolicy, type: :policy do
  let(:court) { FactoryBot.create(:court) }
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: court) }

  describe 'permissions' do
    context 'when role is registrar' do
      subject { described_class.new(registrar_user, court_case) }

      let(:registrar_user) { FactoryBot.create(:user, :registrar) }

      it { is_expected.to permit_actions(%i[index update create statistics]) }
    end

    context 'when role is judge' do
      subject { described_class.new(judge_user, court_case) }

      let(:judge_user) { FactoryBot.create(:user, :judge) }

      it { is_expected.to permit_actions(%i[index statistics]) }
    end

    context 'when role is clerk' do
      subject { described_class.new(clerk_user, court_case) }

      let(:clerk_user) { FactoryBot.create(:user, :clerk) }

      it { is_expected.to permit_actions(%i[index update statistics]) }
    end
  end
end
