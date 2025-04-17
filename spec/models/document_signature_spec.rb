# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentSignature, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :signer }
    it { is_expected.to validate_presence_of :signature_data }
    it { is_expected.to validate_presence_of :signed_at }
  end

  context 'when validating association' do
    it { is_expected.to belong_to :signer }
  end
end
