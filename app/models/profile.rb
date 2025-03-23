# frozen_string_literal: true

# Profile Model
class Profile < ApplicationRecord
  belongs_to :user
  has_many :addresses, dependent: :destroy
  accepts_nested_attributes_for :addresses

  enum :gender, { male: 0, female: 1, other: 2 }

  validates :first_name, :last_name, :cid_no, :phone_number, presence: true
  validates :cid_no, uniqueness: { case_sensitive: false }
end
