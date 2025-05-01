# frozen_string_literal: true

# Profile Json Serializer
class ProfileSerializer
  include JSONAPI::Serializer
  attributes :id, :avatar, :first_name, :last_name, :cid_no, :phone_number, :house_no, :thram_no, :age, :gender

  has_many :addresses, serializer: AddressSerializer

  attribute :gender do |object|
    object.gender.humanize
  end

  attribute :avatar do |object|
    if object.avatar.attached?
      {
        avatar: Rails.application.routes.url_helpers.url_for(object.avatar)
      }
    end
  end
end
