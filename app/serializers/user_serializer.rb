# frozen_string_literal: true

# User Json Serializer
class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email
end
