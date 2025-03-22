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
    it { is_expected.to belong_to(:court).optional }
  end

  describe '#after_confirmation' do
    let!(:user) { FactoryBot.create(:user) }

    before do
      user.confirm
      user.reload
    end

    context 'when generating key' do
      it { expect(user.public_key).to match(/BEGIN PUBLIC KEY/) }
      it { expect(user.private_key).to be_present }

      it 'stores encrypted private key in database' do
        encrypted_value = ActiveRecord::Base.connection.execute(
          "SELECT private_key FROM users WHERE id = #{user.id}"
        ).first['private_key']
        expect(encrypted_value).not_to match(/BEGIN EC PRIVATE KEY/)
      end
    end
  end
end
