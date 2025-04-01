# frozen_string_literal: true

# Hearing Schedule Model
class HearingSchedule < ApplicationRecord
  belongs_to :hearing
  belongs_to :scheduled_by, class_name: 'User'

  enum :schedule_status, { pending: 0, approved: 1, rescheduled: 2, cancelled: 3 }

  validates :schedule_status, :scheduled_date, presence: true
end
