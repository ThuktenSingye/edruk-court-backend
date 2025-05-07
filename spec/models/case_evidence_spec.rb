# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseEvidence, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :evidence_status }
  end

  context 'when validating association' do
    it { is_expected.to have_many :document_signatures }
    it { is_expected.to have_one_attached :evidence }
  end
end
