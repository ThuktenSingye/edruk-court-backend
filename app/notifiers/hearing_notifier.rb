# frozen_string_literal: true

# To deliver this notification:
#
# HearingNotifier.with(record: @post, message: "New post").deliver(User.all)

# Hearing Notification Notifier Class
class HearingNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = 'NotificationChannel' # Custom channel name
    config.stream = -> { "notifications:#{recipient.id}" }
    config.message = -> { params }
  end

  required_params :message, :case, :hearing, :hearing_schedule

  validates :record, presence: true

  def to_database
    {
      type: self.class.name,
      params: params,
      metadata: {
        created_at: Time.zone.now.iso8601,
        court_id: params[:case]&.court_id,
        priority: case_priority
      }
    }
  end

  def to_action_cable
    {
      id: record.id,
      type: self.class.name,
      message: message,
      record: record,
      url: url,
      case_number: params[:case]&.case_number,
      hearing_type: params.dig(:hearing, :hearing_type, :name),
      priority: case_priority
    }
  end

  notification_methods do
    def message
      HearingMessageBuilder.new(
        message_type: params[:message],
        hearing_type: params.dig(:hearing, :hearing_type, :name),
        case_id: params.dig(:case, :id),
        scheduled_date: params.dig(:hearing_schedule, :scheduled_date),
        new_scheduled_date: params.dig(:hearing, :new_scheduled_date),
        schedule_status: params.dig(:hearing, :schedule_status)
      ).build
    end

    def url
      Rails.application.routes.url_helpers.hearing_path(params[:hearing])
    end
  end

  private

  def case_priority
    params[:case]&.case_priority || 'low'
  end
end
