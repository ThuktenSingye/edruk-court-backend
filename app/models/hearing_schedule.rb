# frozen_string_literal: true

# Hearing Schedule Model
class HearingSchedule < ApplicationRecord
  belongs_to :hearing
  belongs_to :scheduled_by, class_name: 'User'
  has_one :case, through: :hearing
  has_one :hearing_type, through: :hearing

  enum :schedule_status, { pending: 0, approved: 1, changes_requested: 2, rescheduled: 3, cancelled: 4 }

  validates :schedule_status, :scheduled_date, presence: true

  delegate :title, :case_number, to: :case, prefix: true, allow_nil: true
  delegate :hearing_status, to: :hearing, prefix: true, allow_nil: true
  delegate :name, to: :hearing_type, prefix: true, allow_nil: true

  scope :for_accessible_courts, lambda { |court_ids|
    joins(hearing: :case)
      .where(
        'cases.court_id IN (:court_ids) OR cases.bench_id IN (:court_ids)',
        court_ids: court_ids
      )
  }

  scope :for_accessible_cases, lambda { |current_user|
    joins(hearing: { case: :case_participants })
      .where(case_participants: { user_id: current_user.id,
                                  role_id: Role.where(name: %w[Defendant Plaintiff Lawyer]).select(:id) })
  }

  scope :today_approved, lambda {
    where(scheduled_date: Time.zone.today.all_day, schedule_status: 'approved')
      .order(scheduled_date: :asc)
      .limit(20)
  }

  scope :pending, lambda {
    where(schedule_status: 'pending')
      .order(scheduled_date: :asc)
      .limit(20)
  }

  scope :overdue, lambda {
    where(scheduled_date: ...Time.zone.today)
      .where(schedule_status: %w[pending approved changes_requested rescheduled])
      .order(scheduled_date: :asc)
      .limit(20)
  }

  scope :reminder, lambda {
    where(scheduled_date: Time.zone.now.beginning_of_day..(Time.zone.now.end_of_day + 1.day))
      .where(schedule_status: 'approved')
      .order(scheduled_date: :asc)
      .limit(10)
  }

  # Helper scopes
  scope :approved, -> { where(schedule_status: 'approved') }
  scope :upcoming, -> { where(scheduled_date: Time.zone.today..) }
end
