# frozen_string_literal: true

# User Json Serializer
class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :court_id, :roles

  attribute :roles do |user|
    user.roles.map(&:name)
  end

  attribute :court_id do |object|
    object.court.id
  end
end
