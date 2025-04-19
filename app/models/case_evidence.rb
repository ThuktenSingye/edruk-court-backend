# frozen_string_literal: true

# Case Evidence Model
class CaseEvidence < ApplicationRecord
  include CaseFile

  has_one_attached :evidence

  enum :evidence_status, { pending: 0, verified: 1, rejected: 2 }
  validates :evidence_status, presence: true
end
