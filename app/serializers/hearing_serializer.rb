# frozen_string_literal: true

# Hearing Serializer
class HearingSerializer
  include JSONAPI::Serializer

  attributes :id, :hearing_status

  attribute :hearing_type do |hearing|
    hearing.hearing_type.name
  end

  attribute :schedules do |hearing|
    hearing.hearing_schedules.map do |schedule|
      {
        id: schedule.id,
        scheduled_date: schedule.scheduled_date.iso8601,
        schedule_status: schedule.schedule_status,
        scheduled_by: schedule.scheduled_by_id
      }
    end
  end
end
