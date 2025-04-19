# frozen_string_literal: true

# Case Document Model
class CaseDocument < ApplicationRecord
  include CaseFile
  has_one_attached :document

  enum :document_status, { pending: 0, verified: 1, denied: 2 }
  validates :document_status, presence: true
end
