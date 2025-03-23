# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :dzongkhag }
    it { is_expected.to validate_presence_of :gewog }
    it { is_expected.to validate_presence_of :street_address }
    it { is_expected.to validate_presence_of :address_type }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :user }
  end
end
