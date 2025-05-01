# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Case, type: :model do
  # rubocop:disable RSpec/LetSetup
  context 'when validating model' do
    let(:court) { create(:court) }
    let(:case_type) { create(:case_type, :civil) }
    let(:case_subtype) { create(:case_subtype, case_type: case_type) }
    let!(:court_case) { create(:case, case_subtype: case_subtype, case_type: case_type, court: court) }

    it { is_expected.to validate_uniqueness_of(:case_number).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:registration_number).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:judgement_number).case_insensitive }
  end
  # rubocop:enable RSpec/LetSetup

  context 'when associating model' do
    it { is_expected.to belong_to(:case_subtype).optional }
    it { is_expected.to belong_to(:case_type).optional }
    it { is_expected.to belong_to(:court) }
    it { is_expected.to have_many :hearings }
  end
end
