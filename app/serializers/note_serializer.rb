# frozen_string_literal: true

# Note Serializer Class
class NoteSerializer
  include JSONAPI::Serializer
  attributes :id, :content, :created_at
end
