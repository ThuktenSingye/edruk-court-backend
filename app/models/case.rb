# frozen_string_literal: true

# Case Model
class Case < ApplicationRecord
  belongs_to :court, optional: false
  belongs_to :bench, class_name: 'Court', optional: true
  belongs_to :case_type, optional: true
  belongs_to :case_subtype, optional: true
  has_many :case_participants, dependent: :destroy
  has_many :hearings, dependent: :destroy
  has_many :hearing_schedules, through: :hearings
  has_many :case_documents, dependent: :nullify
  accepts_nested_attributes_for :case_documents
  after_commit :set_initial_status, on: :create

  enum :case_status, { filed: 0, pending: 1, active: 2, dismissed: 3, withdrawn: 4, settled: 5, closed: 6 }
  enum :case_priority, { low: 0, medium: 1, high: 2, critical: 3 }

  # validates :case_number, :registration_number, :judgement_number, uniqueness: { case_sensitive: false }

  private

  def set_initial_status
    update!(case_status: :filed)
  end
end
