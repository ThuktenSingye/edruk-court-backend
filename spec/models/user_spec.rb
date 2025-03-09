# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :password }
    it { is_expected.to validate_confirmation_of :password }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  context 'when associating model' do
    it { is_expected.to have_many(:user_roles).dependent(:destroy) }
    it { is_expected.to have_many(:roles).through(:user_roles) }
  end
end
