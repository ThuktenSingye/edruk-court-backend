# frozen_string_literal: true

# Notification Service Class
class NotificationService
  def initialize(court_case, hearing)
    @case = court_case
    @hearing = hearing
  end

  def notify_judge(judge)
    return unless judge

    message_type = find_message_type

    HearingNotifier.with(notifications_params(message_type)).deliver(judge)
  end

  def notify_clerk; end

  def notify_case_participant; end

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
