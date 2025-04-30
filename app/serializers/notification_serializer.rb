# frozen_string_literal: true

# Notification Serializer
class NotificationSerializer
  include JSONAPI::Serializer
  attributes :id, :type, :created_at, :read_at, :params
end
