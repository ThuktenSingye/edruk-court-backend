# frozen_string_literal: true

# To deliver this notification:
#
# HearingNotifier.with(record: @post, message: "New post").deliver(User.all)

# Hearing Notification Notifier Class
class HearingNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = 'NotificationChannel' # Custom channel name
    config.stream = -> { recipients }
    config.message = lambda {
      {
        id: record.id,
        type: self.class.name,
        message: message,
        record: record,
        url: url,
        case_number: params[:case]&.case_number,
        hearing_type: params[:hearing]&.hearing_type&.name
      }
    }
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

  notification_methods do
    def message
      hearing = params[:hearing]
      hearing_schedule = params[:hearing_schedule]
      case_obj = params[:case]

      Hearings::HearingMessageBuilder.new(
        message_type: params[:message].to_sym,
        hearing_type: hearing.hearing_type&.name, # Access association directly
        case_id: case_obj&.id,
        scheduled_date: hearing_schedule&.scheduled_date,
        hearing_status: hearing&.hearing_status
      ).build
    end

    def url
      hearing = params[:hearing]
      case_obj = params[:case]
      Rails.application.routes.url_helpers.api_v1_case_hearing_path(case_obj.id, hearing.id)
    end
  end

  private

  def case_priority
    params[:case]&.case_priority || 'low'
  end
end
