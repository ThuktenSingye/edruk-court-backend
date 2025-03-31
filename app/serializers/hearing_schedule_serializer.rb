# frozen_string_literal: true

# Hearing Schedule Serializer
class HearingScheduleSerializer
  include JSONAPI::Serializer
  attributes :id, :scheduled_date, :schedule_status, :reschedule_reason, :scheduled_by

  attribute :schedule_status do |object|
    object.schedule_status.humanize
  end
end
