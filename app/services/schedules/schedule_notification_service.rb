# frozen_string_literal: true

module Schedules
  # Schedule Notification Service
  class ScheduleNotificationService
    def initialize(court_case, hearing, hearing_schedule)
      @case = court_case
      @hearing = hearing
      @hearing_schedule = hearing_schedule
    end

    def notify_user(user, message_type)
      return unless user

      HearingScheduleNotifier.with(notifications_params(message_type)).deliver(user)
    end

    def notify_case_participant(message_type, current_user)
      users = @case.case_participants.reject { |cp| cp.user&.id == current_user.id }
      # users = @case.case_participants.map(&:user).reject { |user| user.id == current_user.id }
      HearingScheduleNotifier.with(notifications_params(message_type)).deliver(users)
    end

    private

    def notifications_params(message)
      {
        record: @hearing,
        message: message,
        hearing: @hearing,
        hearing_schedule: @hearing.hearing_schedules.last,
        case: @case
      }
    end
  end
end
