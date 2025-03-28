# frozen_string_literal: true

# Hearing Type Serializer
class HearingTypeSerializer
  include JSONAPI::Serializer
  attributes :name
end
