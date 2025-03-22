# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EccKeyGenerator, type: :service do
  describe '.generate' do
    subject(:key_pair) { described_class.generate }

    it { expect(key_pair[:private_key]).to be_present }
    it { expect(key_pair[:public_key]).to be_present }
  end
end
