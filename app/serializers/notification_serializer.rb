# frozen_string_literal: true

# Notification Serializer
class NotificationSerializer
  include JSONAPI::Serializer
  attributes :id, :type, :created_at, :read_at, :params, :message, :url, :case_number

  attribute :message do |notification|
    notification.params[:message]
  end

  attribute :url do |notification|
    notification.params[:url]
  end

  attribute :case_number do |notification|
    notification.params[:case_number]
  end
end
