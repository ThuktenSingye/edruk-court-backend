# frozen_string_literal: true

module Noticed
  # Notification Policy Class
  class NotificationPolicy < ApplicationPolicy
    # Notification Scope Class
    class Scope < ApplicationPolicy::Scope
      # NOTE: Be explicit about which records you allow access to!
      def resolve
        scope.where(recipient: user)
      end
    end

    def index?
      true
    end

    def mark_as_read?
      record.recipient == user
    end
  end
end
