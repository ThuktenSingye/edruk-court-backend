# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:user) { FactoryBot.create(:user) }
  # rubocop:disable RSpec/LetSetup
  let!(:profile) { FactoryBot.create(:profile, user: user) }
  # rubocop:enable RSpec/LetSetup

  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :cid_no }
    it { is_expected.to validate_presence_of :phone_number }

    it { is_expected.to validate_uniqueness_of(:cid_no).case_insensitive }
  end

  context 'when associating model' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :addresses }
  end
end
