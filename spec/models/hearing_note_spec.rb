# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingNote, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :content }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :hearing }
    it { is_expected.to belong_to :author }
  end
end
