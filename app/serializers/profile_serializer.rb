# frozen_string_literal: true

# Profile Json Serializer
class ProfileSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name, :cid_no, :phone_number, :house_no, :thram_no, :age, :gender

  has_many :addresses, serializer: AddressSerializer

  attribute :gender do |object|
    object.gender.humanize
  end
end
