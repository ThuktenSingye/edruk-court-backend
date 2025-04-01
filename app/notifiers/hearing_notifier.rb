# frozen_string_literal: true

# To deliver this notification:
#
# HearingNotifier.with(record: @post, message: "New post").deliver(User.all)

# Hearing Notification Notifier Class
class HearingNotifier < ApplicationNotifier
  deliver_by :database
  deliver_by :action_cable

  param :case, :hearing, :hearing_schedule

  def message
    hearing_type_name = params.dig(:hearing, :hearing_type, :name) || 'Hearing'

    case params[:message].to_s
    when 'new_hearing'
      scheduled_date = params.dig(:hearing_schedule, :scheduled_date)
      formatted_date = scheduled_date&.strftime('%Y-%m-%d %H:%M:%S') || 'a future date'
      "#{hearing_type_name} Hearing scheduled at #{formatted_date}"

    when 'hearing_update'
      hearing_status = params.dig(:hearing, :hearing_status) || 'updated'
      "#{hearing_type_name} Hearing #{hearing_status}"

    else
      # Default fallback message
      'New hearing notification'
    end
  end

  def url
    Rails.application.routes.url_helpers.hearing_path(params[:hearing])
  end

  def to_database
    {
      type: self.class.name,
      params: params,
      metadata: {
        created_at: Time.zone.now.iso8601,
        court_id: params[:case]&.court_id,
        priority: case_priority,
      }
    }
  end

  def to_action_cable
    {
      id: record.id,
      type: self.class.name,
      message: message,
      url: url,
      created_at: Time.current.iso8601,
      case_number: params[:case]&.case_number,
      hearing_type: params.dig(:hearing, :hearing_type, :name),
      priority: case_priority
    }
  end

  private

  def case_priority
    params[:case]&.case_priority || 'low'
  end
end
