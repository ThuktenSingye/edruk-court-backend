# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of :name }
  end

  context 'when associating model' do
    it { is_expected.to have_many(:user_roles).dependent(:nullify) }
  end
end
