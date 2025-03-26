# frozen_string_literal: true

# Case Model
class Case < ApplicationRecord
  acts_as_tenant :court, optional: false
  belongs_to :case_subtype, optional: true

  enum :case_status, { filed: 0, pending: 1, active: 2, dismissed: 3, withdrawn: 4, settled: 5, closed: 6 }
  enum :case_priority, { low: 0, medium: 1, high: 2, critical: 3 }

  validates :case_number, :registration_number, :judgement_number, uniqueness: { case_sensitive: false }
end
