# frozen_string_literal: true

# Hearing Serializer
class HearingSerializer
  include JSONAPI::Serializer
  attributes :hearing_status

  belongs_to :hearing_type
  has_many :hearing_schedules
end
