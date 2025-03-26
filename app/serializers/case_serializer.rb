# frozen_string_literal: true

# Case Json Serializer
class CaseSerializer
  include JSONAPI::Serializer
  attributes :case_number, :registration_number, :judgement_number, :title, :summary, :case_status, :case_priority

  attribute :case_status do |object|
    object.case_status.humanize
  end

  attribute :case_priority do |object|
    object.case_priority.humanize
  end
end
