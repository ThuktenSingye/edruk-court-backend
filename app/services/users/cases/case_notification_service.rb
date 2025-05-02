# frozen_string_literal: true

module Users
  module Cases
    # Case Notification Service
    class CaseNotificationService
      def initialize(court_case)
        @case = court_case
      end

      def notify_registrar(court_id)
        return unless court_id

        registrars = User.where(court_id: court_id).with_role(:Registrar)

        registrars.find_each do |user|
          CaseNotifier.with(notifications_params).deliver(user)
        end
      end

      private

      def notifications_params
        {
          record: @case,
          message: 'New Case Notification',
          url: build_url,
          case: @case
        }
      end

      def build_url
        Rails.application.routes.url_helpers.api_v1_case_path(@case.id)
      end
    end
  end
end
