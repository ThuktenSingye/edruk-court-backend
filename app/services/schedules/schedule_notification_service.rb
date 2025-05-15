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
      participants = @case.case_participants.reject { |cp| cp.user&.id == current_user.id }
      users = ActsAsTenant.without_tenant do
        participants.map { |p| User.unscoped.find_by(id: p.user_id) }.compact
      end
      registrar_users = registrars
      notify_users = (users + registrar_users).uniq.reject { |u| u.id == current_user.id }

      HearingScheduleNotifier.with(notifications_params(message_type)).deliver(notify_users)
    end

    private

    def registrars
      case_court = @case.court
      court = case_court.bench? ? case_court.parent_court : case_court
      User.unscoped.where(court: court).with_role(:Registrar)
    end

    def notifications_params(message)
      {
        record: @hearing,
        message: build_message(message),
        hearing: @hearing,
        url: build_url,
        hearing_schedule: @hearing_schedule,
        case: @case
      }
    end

    def build_message(message_type)
      # hearing_schedule = @hearing.hearing_schedules.last

      Schedules::ScheduleMessageBuilder.new(
        message_type: message_type.to_sym,
        hearing_type: @hearing.hearing_type&.name,
        case_id: @case&.id,
        scheduled_date: @hearing_schedule&.scheduled_date,
        hearing_status: @hearing&.hearing_status
      ).build
    end

    def build_url
      Rails.application.routes.url_helpers.api_v1_case_hearing_hearing_schedule_path(@case.id, @hearing.id,
                                                                                     @hearing_schedule.id)
      # Rails.application.routes.url_helpers.api_v1_case_hearing_path(@case.id, @hearing.id)
    end
  end
end
