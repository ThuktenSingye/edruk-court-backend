# frozen_string_literal: true

# Case Document Model
class CaseDocument < ApplicationRecord
  belongs_to :hearing
  has_one_attached :document
  has_many :document_signatures, as: :signable, dependent: :destroy

  enum :document_status, { pending: 0, verified: 1, denied: 2 }

  validates :hash_value, :document_status, presence: true
  validates :hash_value, uniqueness: { case_sensitive: false }

  scope :pre_hearing, lambda {
    joins(hearing: :hearing_type)
      .where(hearing_types: { name: 'miscellaneous' })
  }

  scope :post_hearing, lambda {
    joins(hearing: :hearing_type)
      .where.not(hearing_types: { name: 'miscellaneous' })
  }
end
