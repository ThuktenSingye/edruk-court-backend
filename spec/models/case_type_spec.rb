# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseType, type: :model do
  context 'when validating model' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_uniqueness_of(:title).case_insensitive }
  end

  context 'when associating model' do
    it { is_expected.to have_many :case_subtypes }
  end
end
