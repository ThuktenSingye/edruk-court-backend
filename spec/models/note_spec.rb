# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :content }
  end

  context 'when validating association' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :hearing }
  end
end
