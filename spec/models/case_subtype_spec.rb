# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseSubtype, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :title }
  end

  context 'when validating uniqueness of title' do
    let(:case_type) { FactoryBot.create(:case_type) }
    # rubocop:disable RSpec/LetSetup
    let!(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
    # rubocop:enable RSpec/LetSetup

    it { is_expected.to validate_uniqueness_of(:title).case_insensitive }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :case_type }
  end
end
