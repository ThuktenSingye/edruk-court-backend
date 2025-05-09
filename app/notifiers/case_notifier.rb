# frozen_string_literal: true

# To deliver this notification:
#
# CaseNotifier.with(record: @post, message: "New post").deliver(User.all)

# Case Notifier Class
class CaseNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = 'NotificationChannel'
    config.stream = -> { recipient }
    config.message = lambda {
      {
        id: record.id,
        type: self.class.name,
        message: message,
        record: record,
        url: url
      }
    }
  end

  required_params :message, :case

  validates :record, presence: true

  def to_database
    {
      type: self.class.name,
      params: params,
      metadata: {
        created_at: Time.zone.now.iso8601,
        court_id: params[:case]&.court_id
      }
    }
  end

  notification_methods do
    def message
      'New Case Notification'
    end

    def url
      Rails.application.routes.url_helpers.api_v1_case_path(params[:case].id)
    end
  end
end
