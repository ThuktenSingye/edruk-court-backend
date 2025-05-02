# frozen_string_literal: true

# Case Document Model
class CaseDocument < ApplicationRecord
  include CaseFile
  has_one_attached :document
  after_commit :set_initial_status, on: :create

  enum :document_status, { pending: 0, verified: 1, denied: 2 }

  def document_url
    document.attached? ? Rails.application.routes.url_helpers.url_for(document) : nil
  end

  private

  def set_initial_status
    update(document_status: :pending)
  end
end
