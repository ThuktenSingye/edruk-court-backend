# frozen_string_literal: true

# Hearing Schedule Serializer
class HearingScheduleSerializer
  include JSONAPI::Serializer
  attributes :id, :scheduled_date, :schedule_status, :reschedule_reason, :scheduled_by, :case_title,
             :case_number, :hearing_status, :hearing_type_name

  attribute :schedule_status do |object|
    object.schedule_status.humanize
  end

  attribute :case_title, &:case_title

  attribute :case_number, &:case_case_number

  attribute :hearing_status do |object|
    object.hearing_hearing_status.humanize
  end

  attribute :hearing_type_name do |object|
    object.hearing_type_name.humanize
  end

  attribute :scheduled_by do |object|
    if object.scheduled_by
      {
        id: object.scheduled_by.id,
        first_name: object.scheduled_by.profile.first_name,
        last_name: object.scheduled_by.profile.last_name
      }
    end
  end
end
