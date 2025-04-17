# frozen_string_literal: true

# Case Evidence Model
class CaseEvidence < ApplicationRecord
  belongs_to :hearing
  has_one_attached :evidence
  has_many :document_signatures, as: :signable, dependent: :destroy

  enum :evidence_status, { pending: 0, verified: 1, rejected: 2 }

  validates :hash_value, :evidence_status, :file_type, presence: true
  validates :hash_value, uniqueness: { case_sensitive: false }
end
