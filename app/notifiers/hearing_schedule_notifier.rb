# frozen_string_literal: true

# To deliver this notification:
#
# HearingScheduleNotifier.with(record: @post, message: "New post").deliver(User.all)
# Schedule Notifier
class HearingScheduleNotifier < ApplicationNotifier
  deliver_by :database

  deliver_by :action_cable do |config|
    config.channel = 'NotificationChannel' # Custom channel name
    config.stream = -> { recipient }
    config.message = lambda {
      {
        id: record.id,
        type: self.class.name,
        message: message,
        record: record,
        url: url,
        case_number: params[:case]&.case_number,
        hearing_type: params[:hearing]&.hearing_type&.name,
        scheduled_date: params[:hearing_schedule]&.scheduled_date
      }
    }
  end

  required_params :case, :message, :hearing, :hearing_schedule

  validates :record, presence: true

  def to_database
    {
      type: self.class.name,
      params: params,
      read_at: nil,
      metadata: {
        created_at: Time.zone.now.iso8601,
        court_id: params[:case]&.court_id,
        message: message,
        url: url
      }
    }
  end

  notification_methods do
    def message
      # Schedules::ScheduleMessageBuilder.new(
      #   message_type: params[:message].to_sym,
      #   hearing_type: params.dig(:hearing, :hearing_type, :name),
      #   case_id: params.dig(:case, :id),
      #   scheduled_date: params.dig(:hearing_schedule, :scheduled_date),
      #   schedule_status: params.dig(:hearing_schedule, :schedule_status)
      # ).build
      Schedules::ScheduleMessageBuilder.new(
        message_type: params[:message].to_sym,
        hearing_type: params[:hearing]&.hearing_type&.name,
        case_id: params[:case]&.id,
        scheduled_date: params[:hearing_schedule]&.scheduled_date,
        schedule_status: params[:hearing_schedule]&.schedule_status
      ).build
    end

    def url
      hearing = params[:hearing]
      case_obj = params[:case]
      schedule = params[:hearing_schedule]
      Rails.application.routes.url_helpers.api_v1_case_hearing_hearing_schedule_path(case_obj.id, hearing.id,
                                                                                     schedule.id)
    end
  end
end
