# frozen_string_literal: true

RSpec.describe Court, type: :model do
  let(:location) { FactoryBot.create(:location) }
  let(:valid_court) { FactoryBot.create(:court, location: location) }

  context 'when validating attributes' do
    before { valid_court }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :court_type }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :contact_no }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:domain).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:subdomain).case_insensitive }
  end

  context 'when associating model' do
    it { is_expected.to belong_to(:parent_court).optional }
    it { is_expected.to have_many :child_courts }
    it { is_expected.to belong_to(:location) }
  end
end
