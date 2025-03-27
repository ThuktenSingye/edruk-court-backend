# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hearing, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :hearing_status }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :case }
    it { is_expected.to have_many :hearing_schedules }
  end
end
