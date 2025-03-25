# frozen_string_literal: true

# Case Model
class Case < ApplicationRecord
  acts_as_tenant :court, optional: false
  belongs_to :case_subtype

  enum :case_status, { Filed: 0, Pending: 1, Active: 2, Dismissed: 3, Withdrawn: 4, Settled: 5, Closed: 6 }
  enum :case_priority, { Low: 0, Medium: 1, High: 2, Critical: 3 }

  validates :case_number, :registration_number, :judgement_number, uniqueness: { case_sensitive: false }
end
