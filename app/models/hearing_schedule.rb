# frozen_string_literal: true

# Hearing Schedule Model
class HearingSchedule < ApplicationRecord
  belongs_to :hearing
  belongs_to :scheduled_by, class_name: 'User'

  enum :schedule_status, { approved: 0, rejected: 1, rescheduled: 2 }

  validates :schedule_status, :scheduled_date, presence: true
end
