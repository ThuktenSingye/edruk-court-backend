# frozen_string_literal: true

module Api
  module V1
    # Notification Controller
    class NotificationsController < ApplicationController
      before_action :authenticate_user!

      def index
        @notifications = current_user.unread_notifications
        authorize @notifications
        render_json :ok, nil, serialized_notifications(@notifications)
      end

      def mark_as_reads
        notification = current_user.notifications.find(params[:id])
        authorize notification, :mark_as_read?, policy_class: Noticed::NotificationPolicy
        notification.mark_as_read!
        render_json :ok, nil, nil
      end

      private

      def serialized_notifications(notifications)
        notifications.map do |notification|
          NotificationSerializer.new(notification).serializable_hash[:data][:attributes]
        end
      end

      def serialized_notification(notification)
        NotificationSerializer.new(notification).serializable_hash[:data][:attributes]
      end
    end
  end
end
