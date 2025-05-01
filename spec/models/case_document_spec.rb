# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/LetSetup
RSpec.describe CaseDocument, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :hash_value }
    it { is_expected.to validate_presence_of :document_status }
  end

  context 'when validating uniqueness of hash value' do
    let(:hearing_type) { create(:hearing_type) }
    let!(:hearing) { create(:hearing, hearing_type: hearing_type) }
    let!(:case_document) { create(:case_document, hearing: hearing) }

    it { is_expected.to validate_uniqueness_of(:hash_value).case_insensitive }
  end

  context 'when validating association' do
    it { is_expected.to have_many :document_signatures }
    it { is_expected.to have_one_attached :document }
  end
  # rubocop:enable RSpec/LetSetup
end
