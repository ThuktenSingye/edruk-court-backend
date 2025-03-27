# frozen_string_literal: true

# Hearing Model
class Hearing < ApplicationRecord
  acts_as_tenant :court, optional: false
  belongs_to :hearing_type
  belongs_to :case
  belongs_to :scheduled_by, class_name: 'User', optional: false

  enum :hearing_status, { accepted: 0, pending: 1, rescheduled: 2, rejected: 3 }

  validates :scheduled_date, :hearing_status, presence: true
end
