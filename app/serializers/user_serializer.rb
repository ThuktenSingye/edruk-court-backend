# frozen_string_literal: true

# User Json Serializer
class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email

  attribute :profile do |object|
    {
      id: object.profile.id,
      first_name: object.profile&.first_name,
      last_name: object.profile&.last_name,
      cid_no: object.profile&.cid_no,
      phone_number: object.profile&.phone_number,
    }
  end

  attribute :court do |object|
    {
      id: object.court&.id,
      name: object.court&.name
    }
  end
end
