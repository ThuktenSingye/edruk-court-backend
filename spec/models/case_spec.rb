# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Case, type: :model do
  context 'when validating model' do
    it { is_expected.to validate_uniqueness_of(:case_number).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:registration_number).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:judgement_number).case_insensitive }
  end

  context 'when associating model' do
    it { is_expected.to belong_to(:case_subtype).optional }
    it { is_expected.to belong_to(:case_type).optional }
    it { is_expected.to belong_to(:court).optional }
  end
end
