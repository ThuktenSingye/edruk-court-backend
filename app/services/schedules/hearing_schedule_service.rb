# frozen_string_literal: true

module Schedules
  # Hearing Schedule Service
  class HearingScheduleService
    delegate :current_tenant, to: :ActsAsTenant

    def initialize(court_case, hearing, hearing_schedule, current_user)
      @court_case = court_case
      @hearing = hearing
      @hearing_schedule = hearing_schedule
      @current_user = current_user
    end

    def notify
      case @hearing_schedule.schedule_status.to_sym
      when :approved, :cancelled, :rescheduled
        notify_case_participants
      when :changes_requested
        notify_scheduler
      else
        Rails.logger.error("Unrecognized schedule status: #{@hearing_schedule.schedule_status}")
      end
    end

    private

    def notify_case_participants
      schedule_notifications_service.notify_case_participant('schedule_update', @current_user)
    end

    def notify_scheduler
      scheduler = current_tenant.users.find_by(id: @hearing_schedule.scheduled_by_id)

      return unless scheduler

      schedule_notifications_service.notify_user(scheduler, 'schedule_update')
    end

    def schedule_notifications_service
      Schedules::ScheduleNotificationService.new(@court_case, @hearing, @hearing_schedule)
    end
  end
end
