# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseDocument, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :document_status }
  end

  context 'when validating association' do
    it { is_expected.to have_many :document_signatures }
    it { is_expected.to have_one_attached :document }
  end
end
