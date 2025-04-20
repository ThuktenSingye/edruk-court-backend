# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Jurisdiction, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :jurisdiction_type }
  end

  context 'when associating model' do
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:child_jurisdictions) }
  end
end
