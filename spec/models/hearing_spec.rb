# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hearing, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :scheduled_date }
    it { is_expected.to validate_presence_of :hearing_status }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :case }
    it { is_expected.to belong_to :hearing_type }
    it { is_expected.to belong_to :scheduled_by }
    it { is_expected.to belong_to(:court).optional }
  end
end
