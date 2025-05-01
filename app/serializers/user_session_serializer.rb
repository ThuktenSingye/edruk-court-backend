# frozen_string_literal: true

# Serializer class for session api
class UserSessionSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :court_id, :roles, :profile

  attribute :roles do |user|
    user.roles.map(&:name)
  end

  attribute :court_id do |object|
    object&.court&.id
  end

  attribute :profile do |object|
    {
      id: object.id,
      first_name: object.profile&.first_name,
      last_name: object.profile&.last_name,
      avatar:
        (Rails.application.routes.url_helpers.url_for(object.profile&.avatar) if object.profile&.avatar&.attached?)
    }
  end
end
