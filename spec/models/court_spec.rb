require 'rails_helper'

RSpec.describe Court, type: :model do
  context 'when validating attributes' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :contact_no }
    it { is_expected.to validate_uniqueness_of :name }
    it { is_expected.to validate_uniqueness_of :email }
    it { is_expected.to validate_uniqueness_of :domain }
    it { is_expected.to validate_uniqueness_of :subdomain }
  end

  context 'when associating model' do
    it { is_expected.to belong_to(:parent_court).optional }
    it { is_expected.to have_many :child_courts }
  end
end
