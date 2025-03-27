# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingSchedule, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :scheduled_date }
    it { is_expected.to validate_presence_of :schedule_status }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :hearing }
    it { is_expected.to belong_to :scheduled_by }
  end
end
