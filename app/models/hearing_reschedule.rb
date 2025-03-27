# Hearing Rescheduled Model
class HearingReschedule < ApplicationRecord
  belongs_to :hearing
  belongs_to :rescheduled_by, class_name: 'User'

  validates :original_date, :new_date, presence: true
end
