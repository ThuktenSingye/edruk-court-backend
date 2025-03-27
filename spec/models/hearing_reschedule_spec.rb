require 'rails_helper'

RSpec.describe HearingReschedule, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :original_date }
    it { is_expected.to validate_presence_of :new_date }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :hearing }
    it { is_expected.to belong_to :rescheduled_by }
  end
end
