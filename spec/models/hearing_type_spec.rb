# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingType, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
