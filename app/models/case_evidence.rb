# frozen_string_literal: true

# Case Evidence Model
class CaseEvidence < ApplicationRecord
  include CaseFile

  has_one_attached :evidence
  after_commit :set_initial_status, on: :create

  enum :evidence_status, { pending: 0, verified: 1, rejected: 2 }
  validates :evidence_status, presence: true

  def evidence_url
    evidence.attached? ? Rails.application.routes.url_helpers.url_for(evidence) : nil
  end

  private

  def set_initial_status
    update(evidence_status: :pending)
  end
end
