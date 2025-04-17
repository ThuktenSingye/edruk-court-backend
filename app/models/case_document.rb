# frozen_string_literal: true

# Case Document Model
class CaseDocument < ApplicationRecord
  belongs_to :hearing
  has_one_attached :document
  has_many :document_signatures, as: :signable, dependent: :destroy

  enum :document_status, { pending: 0, verified: 1, rejected: 2 }

  validates :hash_value, :document_status, presence: true
  validates :hash_value, uniqueness: { case_sensitive: false }
end
