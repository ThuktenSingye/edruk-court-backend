# frozen_string_literal: true

module Hearings
  # Notification Service Class
  class HearingNotificationService
    def initialize(court_case, hearing)
      @case = court_case
      @hearing = hearing
    end

    def notify_user(user)
      return unless user

      message_type = find_message_type

      HearingNotifier.with(notifications_params(message_type)).deliver(user)
    end

    def notify_case_participant(message_type, current_user)
      users = @case.case_participants.map(&:user).reject { |user| user.id == current_user.id }
      HearingNotifier.with(notifications_params(message_type)).deliver(users)
    end

    private

    def find_message_type
      pre_hearing? ? 'pre_hearing' : 'post_hearing'
    end

    def pre_hearing?
      miscellaneous? || preliminary?
    end

    def miscellaneous?
      @hearing.hearing_type.name.downcase == 'miscellaneous'
    end

    def preliminary?
      @hearing.hearing_type.name.downcase == 'preliminary'
    end

    def notifications_params(message_type)
      {
        record: @hearing,
        message: build_message(message_type),
        hearing: @hearing,
        url: build_url,
        hearing_schedule: @hearing.hearing_schedules.last,
        case: @case
      }
    end

    def build_message(message_type)
      hearing_schedule = @hearing.hearing_schedules.last

      Hearings::HearingMessageBuilder.new(
        message_type: message_type.to_sym,
        hearing_type: @hearing.hearing_type&.name,
        case_id: @case&.id,
        scheduled_date: hearing_schedule&.scheduled_date,
        hearing_status: @hearing&.hearing_status
      ).build
    end

    def build_url
      Rails.application.routes.url_helpers.api_v1_case_hearing_path(@case.id, @hearing.id)
    end
  end
end
