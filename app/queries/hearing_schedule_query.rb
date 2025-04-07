# frozen_string_literal: true

# Hearing Schedule Query Class
class HearingScheduleQuery
  def initialize(hearing)
    @relation = hearing.hearing_schedules.all
  end

  def for_reminders
    @relation.where(scheduled_date: [today, tomorrow],
                    schedule_status: 'approved').order(scheduled_date: :asc).limit(10)
  end

  def for_today
    @relation.where(scheduled_date: today, schedule_status: 'approved').order(scheduled_date: :asc).limit(20)
  end

  def for_pending
    @relation.where(schedule_status: 'pending').order(scheduled_date: :asc).limit(20)
  end

  def for_overdue
    @relation.where(scheduled_date: ...today)
             .where(schedule_status: %w[pending approved changes_requested rescheduled])
             .order(scheduled_date: :asc).limit(20)
  end

  private

  def today
    Time.zone.today
  end

  def tomorrow
    today + 1.day
  end
end
